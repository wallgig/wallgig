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
#  primary_color_id    :integer
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
#
# Indexes
#
#  index_wallpapers_on_approved_at       (approved_at)
#  index_wallpapers_on_approved_by_id    (approved_by_id)
#  index_wallpapers_on_image_hash        (image_hash)
#  index_wallpapers_on_primary_color_id  (primary_color_id)
#  index_wallpapers_on_purity            (purity)
#  index_wallpapers_on_user_id           (user_id)
#

class Wallpaper < ActiveRecord::Base
  serialize :cached_tag_list, Array

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

  has_many :wallpaper_colors, -> { order('wallpaper_colors.percentage DESC') }, dependent: :destroy
  has_many :colors, through: :wallpaper_colors, class_name: 'Kolor'
  has_one :primary_wallpaper_color, -> { order('wallpaper_colors.percentage DESC') }, class_name: 'WallpaperColor'
  has_one :primary_color, through: :primary_wallpaper_color, class_name: 'Kolor', source: :color

  has_many :favourites, dependent: :destroy
  has_many :favourited_users, through: :favourites, source: :wallpaper

  has_many :collections_wallpapers, dependent: :destroy
  has_many :collections, through: :collections_wallpapers

  has_many :wallpapers_tags, dependent: :destroy
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
  after_create :queue_process_image
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
          properties: {
            hex: { type: 'string', analyzer: 'keyword', index: 'not_analyzed' },
            percentage: { type: 'integer' }
          }
        },
        aspect_ratio: { type: 'float' },
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
      color: wallpaper_colors.includes(:color).map { |color| { hex: color.hex, percentage: (color.percentage * 10).ceil } },
      aspect_ratio: aspect_ratio,
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

  def extract_colors
    return unless image.present? && image.format == 'jpeg'

    histogram = Colorscore::Histogram.new(image.path)

    # self.primary_color = Kolor.find_or_create_by_color(histogram.scores.first[1])

    # dominant_colors = Miro::DominantColors.new(image.path)
    # hexes = dominant_colors.to_hex
    # rgbs = dominant_colors.to_rgb
    # percentages = dominant_colors.by_percentage

    # # clear any old colors
    # self.primary_color = nil
    wallpaper_colors.clear

    # hexes.each_with_index do |hex, i|
    #   hex = hex[1..-1]
    #   color = Kolor.find_or_create_by(hex: hex, red: rgbs[i][0], green: rgbs[i][1], blue: rgbs[i][2])
    #   self.primary_color = color if i == 0
    #   self.wallpaper_colors.create color: color, percentage: percentages[i]
    # end

    palette = Colorscore::Palette.default
    scores = palette.scores(histogram.scores)

    scores.each do |score|
      color = Kolor.find_or_create_by_color(score[1])
      self.wallpaper_colors.create(color: color, percentage: score[0])
    end

    touch
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

  def queue_process_image
    WallpaperAttributeUpdateWorker.perform_async(id, 'process_image')
  end

  def process_image
    extract_colors
  end

  def resolutions
    @resolutions ||= WallpaperResolutions.new(self)
  end

  attr_reader :resized_image
  attr_reader :resized_image_resolution

  def resize_image_to(resolution)
    return false unless resolutions.include?(resolution)
    @resized_image = image.thumb("#{resolution.to_geometry_s}\##{image_gravity}")
    @resized_image_resolution = resolution
    true
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
    cached_tag_list
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

  def update_tag_ids_by_user(new_tag_ids, user)
    new_tag_ids ||= []
    new_tag_ids.map!(&:to_i)

    tag_ids_to_add    = new_tag_ids - tag_ids
    tag_ids_to_remove = tag_ids - new_tag_ids

    wallpapers_tags.where(tag_id: tag_ids_to_remove).delete_all if tag_ids_to_remove.any?

    Tag.where(id: tag_ids_to_add).pluck(:id).each do |tag_id|
      wallpapers_tags.create!(tag_id: tag_id, added_by_id: user.id)
    end

    cache_tag_list
  end

  def queue_notify_subscribers
    NotifySubscribers.perform_async('User', user_id, id, persisted? && approved?)
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
