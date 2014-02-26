# == Schema Information
#
# Table name: tags
#
#  id                       :integer          not null, primary key
#  name                     :string(255)
#  slug                     :string(255)
#  category_id              :integer
#  purity                   :string(255)
#  coined_by_id             :integer
#  approved_by_id           :integer
#  approved_at              :datetime
#  sfw_wallpapers_count     :integer          default(0)
#  sketchy_wallpapers_count :integer          default(0)
#  nsfw_wallpapers_count    :integer          default(0)
#
# Indexes
#
#  index_tags_on_approved_by_id  (approved_by_id)
#  index_tags_on_category_id     (category_id)
#  index_tags_on_coined_by_id    (coined_by_id)
#  index_tags_on_purity          (purity)
#  index_tags_on_slug            (slug) UNIQUE
#

class Tag < ActiveRecord::Base
  belongs_to :category
  belongs_to :coined_by, class_name: 'User'

  has_many :wallpapers_tags, dependent: :destroy
  has_many :wallpapers, through: :wallpapers_tags

  delegate :name, to: :category, prefix: true, allow_nil: true

  include Approvable
  include HasPurity
  include Subscribable

  extend FriendlyId
  friendly_id :name, use: :slugged

  include PurityCounters
  has_purity_counters :wallpapers

  include PgSearch
  pg_search_scope :search_names, against: :name

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }

  scope :name_like,               -> (query) { where('name ILIKE ?', "#{query}%") }
  scope :alphabetically,          -> { order 'LOWER(name) ASC' }
  scope :in_category_and_subtree, -> (category) { where(category_id: category.subtree_ids) if category.present? }

  before_validation :set_slug, if: :name_changed?

  after_commit :queue_update_wallpaper_tags, on: [:create, :update]

  def self.ensure_consistency!
    connection.execute('
      UPDATE tags t
      SET
        sfw_wallpapers_count = (
          SELECT     COUNT(*)
          FROM       wallpapers_tags wt
          INNER JOIN wallpapers w
          ON         wt.wallpaper_id = w.id
          WHERE      wt.tag_id = t.id
            AND      w.purity = \'sfw\'
        ),
        sketchy_wallpapers_count = (
          SELECT     COUNT(*)
          FROM       wallpapers_tags wt
          INNER JOIN wallpapers w
          ON         wt.wallpaper_id = w.id
          WHERE      wt.tag_id = t.id
            AND      w.purity = \'sketchy\'
        ),
        nsfw_wallpapers_count = (
          SELECT     COUNT(*)
          FROM       wallpapers_tags wt
          INNER JOIN wallpapers w
          ON         wt.wallpaper_id = w.id
          WHERE      wt.tag_id = t.id
            AND      w.purity = \'nsfw\'
        )
    ')
  end

  def set_slug
    self.slug = name.parameterize
  end

  def queue_update_wallpaper_tags
    CacheWallpaperTags.perform_async(tag_id: id)
  end
end
