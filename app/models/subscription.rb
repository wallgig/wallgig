# == Schema Information
#
# Table name: subscriptions
#
#  id                                     :integer          not null, primary key
#  user_id                                :integer
#  subscribable_id                        :integer
#  subscribable_type                      :string(255)
#  last_visited_at                        :datetime
#  created_at                             :datetime
#  updated_at                             :datetime
#  sfw_subscriptions_wallpapers_count     :integer          default(0), not null
#  sketchy_subscriptions_wallpapers_count :integer          default(0), not null
#  nsfw_subscriptions_wallpapers_count    :integer          default(0), not null
#
# Indexes
#
#  index_subscriptions_on_subscribable_id_and_subscribable_type  (subscribable_id,subscribable_type)
#  index_subscriptions_on_user_id                                (user_id)
#

class Subscription < ActiveRecord::Base
  include Notifiable

  belongs_to :user
  belongs_to :subscribable, polymorphic: true

  has_many :subscriptions_wallpapers, dependent: :destroy
  has_many :wallpapers, -> { order(created_at: :desc) }, through: :subscriptions_wallpapers

  include PurityCounters
  has_purity_counters :subscriptions_wallpapers

  validates :subscribable, presence: true
  validates :user, presence: true, uniqueness: { scope: [:subscribable_id, :subscribable_type] }

  before_create do
    self.last_visited_at = Time.now
  end

  after_create :notify

  scope :by_type, -> (type) { where(subscribable_type: type) }
  scope :by_type_with_includes, -> (type) {
    relation = by_type(type)

    case type
    when 'User'
      relation.includes(subscribable: :profile)
    when 'Collection'
      relation.includes(subscribable: { user: :profile })
    else
      relation.includes(:subscribable)
    end
  }

  def self.ensure_consistency!
    connection.execute('
      UPDATE subscriptions s
      SET
        sfw_subscriptions_wallpapers_count = (
          SELECT     COUNT(*)
          FROM       subscriptions_wallpapers sw
          INNER JOIN wallpapers w
          ON         sw.wallpaper_id = w.id
          WHERE      sw.subscription_id = s.id
            AND      w.purity = \'sfw\'
        ),
        sketchy_subscriptions_wallpapers_count = (
          SELECT     COUNT(*)
          FROM       subscriptions_wallpapers sw
          INNER JOIN wallpapers w
          ON         sw.wallpaper_id = w.id
          WHERE      sw.subscription_id = s.id
            AND      w.purity = \'sketchy\'
        ),
        nsfw_subscriptions_wallpapers_count = (
          SELECT     COUNT(*)
          FROM       subscriptions_wallpapers sw
          INNER JOIN wallpapers w
          ON         sw.wallpaper_id = w.id
          WHERE      sw.subscription_id = s.id
            AND      w.purity = \'nsfw\'
        )
    ')
  end

  def mark_all_as_read!
    subscriptions_wallpapers.destroy_all
  end

  def notify
    if subscribable_type == 'User'
      notifications.create({
        user:    subscribable,
        message: I18n.t('subscriptions.notifications.user.message', username: user.username)
      })
    end
  end
end
