# == Schema Information
#
# Table name: wallpapers
#
#  id                    :integer          not null, primary key
#  user_id               :integer
#  purity                :string(255)
#  processing            :boolean          default(TRUE)
#  image_uid             :string(255)
#  image_name            :string(255)
#  image_width           :integer
#  image_height          :integer
#  created_at            :datetime
#  updated_at            :datetime
#  thumbnail_image_uid   :string(255)
#  primary_color_id      :integer
#  impressions_count     :integer          default(0)
#  cached_tag_list       :text
#  image_gravity         :string(255)      default("c")
#  favourites_count      :integer          default(0)
#  purity_locked         :boolean          default(FALSE)
#  source                :string(255)
#  phash                 :integer
#  scrape_source         :string(255)
#  scrape_id             :string(255)
#  image_hash            :string(255)
#  cached_votes_total    :integer          default(0)
#  cached_votes_score    :integer          default(0)
#  cached_votes_up       :integer          default(0)
#  cached_votes_down     :integer          default(0)
#  cached_weighted_score :integer          default(0)
#  comments_count        :integer          default(0)
#  approved_by_id        :integer
#  approved_at           :datetime
#

class Wallpaper < ActiveRecord::Base
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

  include Approvable
  include HasPurity
  include Reportable

  acts_as_votable

  enumerize :image_gravity, in: Dragonfly::ImageMagick::Processors::Thumb::GRAVITIES.keys

  # Image
  attr_readonly :image

  dragonfly_accessor :image

  dragonfly_accessor :thumbnail_image do
    storage_options do |i|
      { path: image_storage_path(i) }
    end
  end

  # Comments
  acts_as_commentable

  # Tags
  serialize :cached_tag_list, Array

  # Pagination
  paginates_per 20

  # Views
  is_impressionable counter_cache: true

  # Paper trail
  # has_paper_trail only: [:purity, :cached_tag_list, :source]

  # Validation
  validates_presence_of :image
  validates_size_of :image,      maximum: 20.megabytes,                       on: :create
  validates_property :mime_type, of: :image, in: ['image/jpeg', 'image/png'], on: :create
  validates_property :width,     of: :image, in: (600..10240),                on: :create
  validates_property :height,    of: :image, in: (600..10240),                on: :create

  unless Rails.env.development?
    validate :check_duplicate_image_hash, on: :create
  end

  # Scopes
  scope :processing,    -> { where(processing: true ) }
  scope :processed,     -> { where(processing: false) }
  scope :visible,       -> { processed }
  scope :latest,        -> { order(created_at: :desc) }
  scope :similar_to,    -> (w) { where.not(id: w.id).where(["( SELECT SUM(((phash::bigint # ?) >> bit) & 1 ) FROM generate_series(0, 63) bit) <= 15", w.phash]) }

  scope :subscribed_users_by_user, -> (user) {
    where(['
      wallpapers.user_id IN (
        SELECT s.subscribable_id
        FROM   subscriptions s
        WHERE  s.user_id = ?
          AND  s.subscribable_type = \'User\'
          AND  s.last_visited_at < wallpapers.created_at
      )
    ', user.id])
  }

  scope :subscribed_collections_by_user, -> (user) {
    where(['
      wallpapers.id IN (
        SELECT     cw.wallpaper_id
        FROM       subscriptions s
        INNER JOIN collections_wallpapers cw
        ON         cw.collection_id = s.subscribable_id
        WHERE      s.user_id = ?
          AND      s.subscribable_type = \'Collection\'
          AND      s.last_visited_at < wallpapers.created_at
      )
    ', user.id])
  }

  scope :subscribed_tags_by_user, -> (user) {
    where(['
      wallpapers.id IN (
        SELECT     wt.wallpaper_id
        FROM       subscriptions s
        INNER JOIN wallpapers_tags wt
        ON         wt.tag_id = s.subscribable_id
        WHERE      s.user_id = ?
          AND      s.subscribable_type = \'Tag\'
          AND      s.last_visited_at < wallpapers.created_at
      )
    ', user.id])
  }

  scope :in_subscription, -> (subscription) {
    case subscription.subscribable_type
    when 'User'
      where(['user_id = ? AND wallpapers.created_at > ?', subscription.subscribable_id, subscription.last_visited_at])
    when 'Tag'
      joins(:tags).where(tags: { id: subscription.subscribable_id }).where('wallpapers.created_at > ?', subscription.last_visited_at)
    when 'Collection'
    else
      none
    end
  }

  # Callbacks
  before_validation :set_image_hash, on: :create

  before_create :auto_approve_if_trusted_user

  after_create :queue_create_thumbnails
  after_create :queue_process_image

  around_save :check_image_gravity_changed

  after_save :update_processing_status, if: :processing?

  unless Rails.env.test?
    after_save :update_index, unless: :processing?
    after_destroy :update_index
  end

  after_commit :queue_notify_subscribers, if: :approved_changed?

  # Search
  # formula to calculate wallpaper's popularity
  POPULARITY_SCRIPT = "doc['views'].value * 0.1 + doc['favourites'].value * 1.0"

  include Tire::Model::Search
  tire.settings :analysis => {
                  :analyzer => {
                    :'string_lowercase' => {
                      :tokenizer => 'keyword',
                      :filter => 'lowercase'
                    }
                  }
                } do
    tire.mapping do
      indexes :user_id,              type: 'integer'
      indexes :user,                 type: 'string',  analyzer: 'keyword', index: 'not_analyzed'
      indexes :purity,               type: 'string',  analyzer: 'keyword', index: 'not_analyzed'
      indexes :tags,                 type: 'string',  analyzer: 'keyword'
      indexes :categories,           type: 'string',  analyzer: 'keyword'
      indexes :width,                type: 'integer'
      indexes :height,               type: 'integer'
      indexes :source,               type: 'string'
      indexes :colors do
        indexes :hex,                type: 'string',  analyzer: 'keyword', index: 'not_analyzed'
        indexes :percentage,         type: 'integer'
      end
      indexes :views,                type: 'integer'
      # indexes :views_today,          type: 'integer'
      # indexes :views_this_week,      type: 'integer'
      indexes :favourites,           type: 'integer'
      # indexes :favourites_today,     type: 'integer' # TODO
      # indexes :favourites_this_week, type: 'integer' # TODO
      indexes :approved,             type: 'boolean'
      indexes :approved_at,          type: 'date'
      indexes :created_at,           type: 'date'
      indexes :updated_at,           type: 'date'
      indexes :aspect_ratio,         type: 'float'
    end
  end

  def to_indexed_json
    {
      user_id:              user_id,
      user:                 user.try(:username),
      purity:               purity,
      tags:                 tag_list,
      categories:           category_list,
      width:                image_width,
      height:               image_height,
      source:               source,
      colors:               wallpaper_colors.includes(:color).map { |color| { hex: color.hex, percentage: (color.percentage * 10).ceil } },
      views:                impressions_count,
      # views_today:          impressionist_count(start_date: Time.now.beginning_of_day),
      # views_this_week:      impressionist_count(start_date: Time.now.beginning_of_week),
      favourites:           cached_votes_total,
      # favourites_today:     favourites.where('created_at >= ?', Time.now.beginning_of_day).size, # FIXME
      # favourites_this_week: favourites.where('created_at >= ?', Time.now.beginning_of_week).size, # FIXME
      approved:             approved?,
      approved_at:          approved_at,
      created_at:           created_at,
      updated_at:           updated_at,
      aspect_ratio:         aspect_ratio
    }.to_json
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
    (image_width.to_f / image_height.to_f).round(2) if has_image_sizes?
  end

  def to_s
    "Wallpaper \##{id}"
  end

  def lock_purity!
    update_attribute :purity_locked, true
  end

  def unlock_purity!
    update_attribute :purity_locked, false
  end

  def update_phash
    # TODO disable this for now
    # return unless image.present?

    # fingerprint = Phashion::Image.new(image.path).fingerprint
    # self.phash = (fingerprint & ~(1 << 63)) - (fingerprint & (1 << 63)) # convert 64 bit unsigned to signed
    # self.save
  end

  def similar_wallpapers
    Wallpaper.similar_to(self)
  end

  def queue_create_thumbnails
    WallpaperResizerWorker.perform_async(id)
  end

  def queue_process_image
    WallpaperAttributeUpdateWorker.perform_async(id, 'process_image')
  end

  def process_image
    extract_colors
    update_phash
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

  def cooked_source
    # OPTIMIZE save to model?
    ApplicationController.helpers.markdown_line(source) if source.present?
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
    NotifySubscribers.perform_async('User', user_id, id, approved?)
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
