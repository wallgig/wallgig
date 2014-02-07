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
#

class Collection < ActiveRecord::Base
  belongs_to :owner, polymorphic: true

  has_many :collections_wallpapers, dependent: :destroy
  has_many :wallpapers, -> { order('collections_wallpapers.position ASC') }, through: :collections_wallpapers

  acts_as_list scope: :owner

  is_impressionable counter_cache: true

  validates :name, presence: true

  paginates_per 20

  scope :public,  -> { where(public: true) }
  scope :private, -> { where(public: false) }
  scope :ordered, -> { order(position: :asc) }
  scope :latest,  -> { order(updated_at: :desc) }

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

    self.class.decrement_counter(counter_name_for(wallpaper), id)
  end

  def collect!(wallpaper)
    collections_wallpapers.create!(wallpaper_id: wallpaper.id)

    self.class.increment_counter(counter_name_for(wallpaper), id)
  end

  def wallpapers_count_for(purities)
    purities.map { |p| read_attribute("#{p}_wallpapers_count") }.reduce(:+)
  end

  private

  def counter_name_for(wallpaper)
    "#{wallpaper.purity}_wallpapers_count"
  end
end
