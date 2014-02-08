# == Schema Information
#
# Table name: collections
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  name                     :string(255)
#  public                   :boolean          default(TRUE)
#  ancestry                 :string(255)
#  position                 :integer
#  created_at               :datetime
#  updated_at               :datetime
#  impressions_count        :integer          default(0)
#  owner_id                 :integer
#  owner_type               :string(255)
#  sfw_wallpapers_count     :integer          default(0)
#  sketchy_wallpapers_count :integer          default(0)
#  nsfw_wallpapers_count    :integer          default(0)
#  last_added_at            :datetime
#

class Collection < ActiveRecord::Base
  belongs_to :owner, polymorphic: true

  has_many :collections_wallpapers, dependent: :destroy
  has_many :wallpapers, through: :collections_wallpapers
  has_many :ordered_wallpapers,        -> { order('collections_wallpapers.position ASC') },    through: :collections_wallpapers, class_name: 'Wallpaper', source: :wallpaper
  has_many :recently_added_wallpapers, -> { order('collections_wallpapers.created_at DESC') }, through: :collections_wallpapers, class_name: 'Wallpaper', source: :wallpaper

  acts_as_list scope: :owner

  is_impressionable counter_cache: true

  validates :name, presence: true

  paginates_per 20

  scope :public,  -> { where(public: true) }
  scope :private, -> { where(public: false) }
  scope :ordered, -> { order(position: :asc) }
  scope :latest,  -> { order(last_added_at: :desc) }

  # scope :has_wallpapers, -> { where.not(wallpapers: { id: nil }) }

  scope :with_purities, -> (purities) {
    purity_conditions = purities.map { |p| "#{counter_name_for(p)} > 0" }
    where(purity_conditions.join(' OR '))
  }

  attr_accessor :collect_status

  def self.ensure_consistency!
    connection.execute('
      UPDATE collections c
      SET
        sfw_wallpapers_count = (
          SELECT COUNT(*)
          FROM wallpapers w
          WHERE w.id IN ( SELECT cw.wallpaper_id FROM collections_wallpapers cw WHERE cw.collection_id = c.id )
            AND w.purity = \'sfw\'
        ),
        sketchy_wallpapers_count = (
          SELECT COUNT(*)
          FROM wallpapers w
          WHERE w.id IN ( SELECT cw.wallpaper_id FROM collections_wallpapers cw WHERE cw.collection_id = c.id )
            AND w.purity = \'sketchy\'
        ),
        nsfw_wallpapers_count = (
          SELECT COUNT(*)
          FROM wallpapers w
          WHERE w.id IN ( SELECT cw.wallpaper_id FROM collections_wallpapers cw WHERE cw.collection_id = c.id )
            AND w.purity = \'nsfw\'
        )
    ')
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def collected?(wallpaper)
    collections_wallpapers.where(wallpaper_id: wallpaper.id).exists?
  end

  def uncollect!(wallpaper)
    collections_wallpapers.find_by!(wallpaper_id: wallpaper.id).destroy

    touch
    self.class.decrement_counter(self.class.counter_name_for(wallpaper), id)
  end

  def collect!(wallpaper)
    collections_wallpapers.create!(wallpaper_id: wallpaper.id)

    touch(:last_added_at)
    self.class.increment_counter(self.class.counter_name_for(wallpaper), id)
  end

  def wallpapers_count_for(purities)
    purities.map { |p| read_attribute(self.class.counter_name_for(p)) }.reduce(:+)
  end

  private

  def self.counter_name_for(wallpaper_or_purity)
    wallpaper_or_purity = wallpaper_or_purity.purity if wallpaper_or_purity.class.name == 'Wallpaper'
    "#{wallpaper_or_purity}_wallpapers_count"
  end
end
