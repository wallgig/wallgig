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
#  sfw_wallpapers_count     :integer          default(0)
#  sketchy_wallpapers_count :integer          default(0)
#  nsfw_wallpapers_count    :integer          default(0)
#  last_added_at            :datetime
#
# Indexes
#
#  index_collections_on_ancestry  (ancestry)
#  index_collections_on_user_id   (user_id)
#

class Collection < ActiveRecord::Base
  belongs_to :user

  has_many :collections_wallpapers, dependent: :destroy
  has_many :wallpapers, through: :collections_wallpapers
  has_many :ordered_wallpapers,        -> { order('collections_wallpapers.position ASC') },    through: :collections_wallpapers, class_name: 'Wallpaper', source: :wallpaper
  has_many :recently_added_wallpapers, -> { order('collections_wallpapers.created_at DESC') }, through: :collections_wallpapers, class_name: 'Wallpaper', source: :wallpaper

  include Subscribable

  acts_as_list scope: :user, top_of_list: 0, add_new_at: :top

  is_impressionable counter_cache: true

  include PurityCounters
  has_purity_counters :wallpapers

  validates :name, presence: true

  scope :ordered, -> { order(position: :asc) }
  scope :latest,  -> { order(last_added_at: :desc) }

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

  def self.ensure_in_list!
    all.each do |collection|
      collection.insert_to_list if collection.not_in_list?
    end
  end

  def self.reset_list_position!
    all.update_all(position: nil)
  end

  def insert_to_list
    insert_at(0)
  end

  def private?
    !public?
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
end
