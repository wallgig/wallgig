# == Schema Information
#
# Table name: wallpapers
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  purity              :string(255)
#  processing          :boolean          default(TRUE)
#  image_uid           :string(255)
#  image_name          :string(255)
#  image_width         :integer
#  image_height        :integer
#  created_at          :datetime
#  updated_at          :datetime
#  thumbnail_image_uid :string(255)
#  impressions_count   :integer          default(0)
#  cached_tag_list     :text
#  image_gravity       :string(255)      default("c")
#  favourites_count    :integer          default(0)
#  source              :text
#  scrape_source       :string(255)
#  scrape_id           :string(255)
#  image_hash          :string(255)
#  comments_count      :integer          default(0)
#  approved_by_id      :integer
#  approved_at         :datetime
#  cooked_source       :text
#  colors              :text
#
# Indexes
#
#  index_wallpapers_on_approved_at     (approved_at)
#  index_wallpapers_on_approved_by_id  (approved_by_id)
#  index_wallpapers_on_image_hash      (image_hash)
#  index_wallpapers_on_purity          (purity)
#  index_wallpapers_on_user_id         (user_id)
#

class Wallpaper < ActiveRecord::Base
  THUMBNAIL_WIDTH = 250
  THUMBNAIL_HEIGHT = 188

  serialize :cached_tag_list, Array
  serialize :colors, JSON

  include Approvable
  include Commentable
  include HasPurity
  include Reportable
  include Cookable

  cookable :source

  is_impressionable counter_cache: true

  paginates_per 20

  enumerize :image_gravity, in: Dragonfly::ImageMagick::Processors::Thumb::GRAVITIES.keys

  #
  # Relations
  #
  belongs_to :user, counter_cache: true

  has_many :favourites, dependent: :destroy
  has_many :favourited_users, through: :favourites, source: :wallpaper

  has_many :collections_wallpapers, dependent: :destroy
  has_many :collections, through: :collections_wallpapers

  has_many :wallpapers_tags, dependent: :destroy,
           before_add: :set_wallpaper_tag_added_by_user

  has_many :tags, through: :wallpapers_tags
  has_many :ordered_tags, -> {
    reorder('
      CASE tags.purity
        WHEN \'sfw\' THEN 3
        WHEN \'sketchy\' THEN 2
        WHEN \'nsfw\' THEN 1
      END DESC,
      name ASC
    ')
  }, through: :wallpapers_tags, source: :tag

  has_many :subscriptions_wallpapers, dependent: :destroy
  has_many :subscriptions, through: :subscriptions_wallpapers

  #
  # Image
  #
  attr_readonly :image

  dragonfly_accessor :image

  dragonfly_accessor :thumbnail_image do
    storage_options do |i|
      { path: image_storage_path(i) }
    end
  end

  #
  # Validations
  #
  validates_presence_of :image
  validates_size_of :image,      maximum: 20.megabytes,                       on: :create
  validates_property :mime_type, of: :image, in: ['image/jpeg', 'image/png'], on: :create
  validates_property :width,     of: :image, in: (600..10240),                on: :create
  validates_property :height,    of: :image, in: (600..10240),                on: :create

  validate :check_duplicate_image_hash, on: :create if Rails.env.production?

  #
  # Scopes
  #
  scope :processing,    -> { where(processing: true ) }
  scope :processed,     -> { where(processing: false) }
  scope :visible,       -> { processed }
  scope :latest,        -> { order(created_at: :desc) }

  #
  # Callbacks
  #
  before_validation :set_image_hash, on: :create
  before_create :auto_approve_if_trusted_user
  after_create :queue_create_thumbnails
  around_save :check_image_gravity_changed
  after_save :update_processing_status, if: :processing?
  after_commit :queue_notify_subscribers

  #
  # Search
  #

  # Formula to calculate wallpaper's popularity
  POPULARITY_SCRIPT = "doc['views'].value * 0.1 + doc['favourites'].value * 1.0"

  searchkick mappings: {
    wallpaper: {
      properties: {
        user_id: { type: 'integer' },
        user: { type: 'string', analyzer: 'keyword', index: 'not_analyzed' },
        purity: { type: 'string', analyzer: 'keyword', index: 'not_analyzed' },
        tag: { type: 'string', analyzer: 'keyword' },
        category: { type: 'string', analyzer: 'keyword' },
        width: { type: 'integer' },
        height: { type: 'integer' },
        color: {
          type: 'nested',
          properties: {
            h: { type: 'integer' },
            s: { type: 'integer' },
            v: { type: 'integer' },
            score: { type: 'integer' }
          }
        },
        aspect_ratio: { type: 'float' },
        created_at: { type: 'date' },
        updated_at: { type: 'date' },
        views: { type: 'integer' },
        favourites: { type: 'integer' }
      }
    }
  }

  def search_data
    {
      user_id: user_id,
      user: user.try(:username),
      purity: purity,
      tag: tag_list,
      category: category_list,
      width: image_width,
      height: image_height,
      color: image_hsl_color_scores,
      aspect_ratio: aspect_ratio,
      created_at: created_at,
      updated_at: updated_at,
      views: impressions_count,
      favourites: favourites_count
    }
  end

  def should_index?
    !processing? && approved?
  end

  def self.ensure_consistency!
    connection.execute('
      UPDATE wallpapers SET favourites_count = (
        SELECT COUNT(*) FROM favourites WHERE favourites.wallpaper_id = wallpapers.id
      )
    ')
  end

  def image_storage_path(i)
    name = File.basename(image_uid, (image.ext || '.jpg'))
    [File.dirname(image_uid), "#{name}_#{i.width}x#{i.height}.#{i.format}"].join('/')
  end

  def update_processing_status
    if has_thumbnails?
      self.processing = false
      save
    end
  end

  def has_thumbnails?
    image.present? && thumbnail_image.present?
  end

  def has_image_sizes?
    image_width.present? && image_height.present?
  end

  def check_image_gravity_changed
    image_gravity_changed = image_gravity_changed?
    yield
    queue_create_thumbnails if image_gravity_changed
  end

  def format
    if image_height.nil? || image_width.nil?
      :unknown
    elsif image_height <= image_width
      :landscape
    else
      :portrait
    end
  end

  def portrait?
    format == :portrait
  end

  def landscape?
    format == :landscape
  end

  def aspect_ratio
    if has_image_sizes?
      factor = 100.0
      ((image_width.to_f / image_height.to_f) * factor).floor / factor
    end
  end

  def to_s
    "Wallpaper \##{id}"
  end

  def queue_create_thumbnails
    WallpaperResizerWorker.perform_async(id)
  end

  def set_image_hash
    self.image_hash = Digest::MD5.file(image.file).hexdigest if image.present?
  end

  def category_list
    category_ids =
      tags
        .where.not(category_id: nil)
        .includes(:category)
        .reject { |tag| tag.category.blank? }
        .map { |tag| tag.category.ancestor_ids << tag.category_id }
        .flatten
        .uniq

    Category.where(id: category_ids).pluck(:name)
  end

  # TODO deprecate
  def tag_list
    cached_tag_list.presence || tags.pluck(:name) # FIXME
  end

  def tag_list_text(glue = ', ')
    tag_list.join(glue)
  end

  def set_cached_tag_list
    self.cached_tag_list = tags.pluck(:name)
  end

  # Save cached tag list
  def cache_tag_list
    set_cached_tag_list
    save
  end

  def queue_notify_subscribers
    NotifySubscribers.perform_async('User', user_id, id, persisted? && approved?)
  end

  # Public: Merges this wallpaper to another wallpaper.
  #
  # other_wallpaper - Wallpaper to copy associations to
  def merge_to(other_wallpaper)
    raise 'Cannot merge two same wallpapers' if self == other_wallpaper

    # Don't move these associations
    excluded_associations = [:wallpaper_colors]

    # Find dependent destroy associations
    dependent_destroy_associations = self.class.reflect_on_all_associations.select do |association|
      association.options[:dependent] == :destroy && !excluded_associations.include?(association.name)
    end

    foreign_key_updater = lambda do |association, record|
      record[association.foreign_key.to_sym] = other_wallpaper.id
      record.save
    end

    self.class.transaction do
      # Change foreign key of associations from this wallpaper to other wallpaper
      dependent_destroy_associations.each do |association|
        if association.collection?
          send(association.name).find_each do |record|
            foreign_key_updater.call(association, record)
          end
        else
          record = send(association.name)
          foreign_key_updater.call(association, record) unless record.nil?
        end
      end

      # Touch other wallpaer (to invalidate cache)
      other_wallpaper.touch

      # Destroy this wallpaper
      destroy
    end
  end

  concerning :ColorIndexing do
    COLOR_SCORE_THRESHOLD = 0.01

    included do
      before_create :set_colors
    end

    def image_color_scores
      @image_color_scores ||= begin
        return unless image.present?
        Colorscore::Histogram.new(image.path).scores.keep_if { |score| score[0] > COLOR_SCORE_THRESHOLD }
      end
    end

    def image_hex_color_scores
      return if image_color_scores.blank?
      image_color_scores.map do |score|
        {
          hex: score[1].to_rgb.hex,
          score: (score[0] * 100).to_i
        }
      end
    end

    def image_hsl_color_scores
      return if image_color_scores.blank?
      image_color_scores.map do |score|
        color = score[1].to_rgb
        r, g, b = color.r, color.g, color.b
        max_rgb = [r, g, b].max
        min_rgb = [r, g, b].min
        delta = max_rgb - min_rgb
        v = max_rgb * 100

        if max_rgb == 0.0
          s = 0.0
        else
          s = delta / max_rgb * 100
        end

        if s == 0.0
          h = 0.0
        else
          if r == max_rgb
            h = (g - b) / delta
          elsif g == max_rgb
            h = 2 + (b - r) / delta
          elsif b == max_rgb
            h = 4 + (r - g) / delta
          end

          h *= 60.0
          h += 360.0 if h < 0
        end

        {
          h: h.to_i,
          s: s.to_i,
          v: v.to_i,
          score: (score[0] * 100).to_i
        }
      end
    end

    private
    def set_colors
      self.colors = image_hex_color_scores
    end
  end

  concerning :Resizing do
    included do
      attr_reader :resized_image
      attr_reader :resized_image_resolution
    end

    def resizable_resolutions
      @resizable_resolutions ||= WallpaperResolutions.new(self)
    end

    # Resizes the image given a ScreenResolution instance
    # @param [Object] check_inclusion Checks if ScreenResolution is in the list of resizable resolutions.
    def resize_image_to(screen_resolution, check_inclusion: true)
      raise ArgumentError, 'Argument is not an instance of ScreenResolution' unless screen_resolution.is_a?(ScreenResolution)
      if check_inclusion && !resizable_resolutions.include?(screen_resolution)
        return false
      end
      @resized_image = image.thumb("#{screen_resolution.to_geometry_s}\##{image_gravity}")
      @resized_image_resolution = screen_resolution
      true
    end

    # Creates a ScreenResolution instance with the original image dimensions.
    def original_image_resolution
      @original_image_resolution ||= ScreenResolution.new(width: image_width, height: image_height)
    end

    # Returns a ScreenResolution instance with the requested image dimensions.
    # Falls back to original image dimensions if not present.
    def requested_image_resolution
      return resized_image_resolution unless resized_image_resolution.nil?
      original_image_resolution
    end
  end

  concerning :Tagging do
    included do
      attr_accessor :editing_user

      validate :check_minimum_two_tags

      extend ClassMethods
    end

    module ClassMethods
      def new_with_editing_user(attributes, editing_user)
        new.tap do |obj|
          obj.editing_user = editing_user
          obj.attributes = attributes
        end
      end
    end

    private
      def set_wallpaper_tag_added_by_user(wallpaper_tag)
        wallpaper_tag.added_by = editing_user unless editing_user.nil?
      end

      def check_minimum_two_tags
        errors.add :tags, 'minimum of two tags are required' if tag_ids.count < 2
      end
  end

  private
    def check_duplicate_image_hash
      if image_hash.present? && (duplicate = self.class.where.not(id: self.id).where(image_hash: image_hash).first)
        errors.add :image, "has already been uploaded (#{duplicate})"
      end
    end

    def auto_approve_if_trusted_user
      self.approved_at = Time.now if user.staff? || user.trusted?
    end
end
