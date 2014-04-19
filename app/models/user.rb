# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  username               :string(255)
#  discourse_user_id      :integer
#  wallpapers_count       :integer          default(0)
#  moderator              :boolean          default(FALSE)
#  admin                  :boolean          default(FALSE)
#  developer              :boolean          default(FALSE)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string(255)
#  locked_at              :datetime
#  authentication_token   :string(255)
#  comments_count         :integer          default(0)
#  trusted                :boolean          default(FALSE)
#
# Indexes
#
#  index_users_on_authentication_token  (authentication_token) UNIQUE
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_discourse_user_id     (discourse_user_id)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#  index_users_on_username              (username) UNIQUE
#

class User < ActiveRecord::Base
  attr_accessor :login

  # Collections
  has_many :collections,
    dependent: :destroy

  # Wallpapers
  has_many :wallpapers,
    dependent: :nullify

  # Favourites
  has_many :favourites,
    dependent: :destroy
  has_many :favourite_wallpapers,
    -> { order("#{Favourite.quoted_table_name}.\"created_at\" DESC") },
    through: :favourites,
    source: :wallpaper

  # Profile
  has_one :profile,
    class_name: 'UserProfile',
    dependent: :destroy

  # Settings
  has_one :settings,
    class_name: 'UserSetting',
    dependent: :destroy

  # Forum topics
  has_many :topics,
    dependent: :destroy

  # Coined tags
  has_many :coined_tags,
    class_name: 'Tag',
    foreign_key: 'coined_by_id',
    dependent: :nullify

  # Subscriptions and subscribers
  has_many :subscriptions,
    dependent: :destroy
  has_many :user_subscriptions,
    through: :subscriptions,
    source: :subscribable,
    source_type: 'User'

  include Subscribable

  # Notifications
  has_many :notifications, dependent: :destroy

  # Comments made
  has_many :comments_made, class_name: 'Comment', dependent: :destroy

  # Comments
  include Commentable

  # Voter
  acts_as_voter

  # Donations
  has_many :donations, dependent: :nullify

  # Devise authentication
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable

  # Views
  is_impressionable

  # Validation
  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: /\A[a-zA-Z0-9_]*[a-zA-Z][a-zA-Z0-9_]*\z/, message: 'Only letters, numbers, and underscores allowed.' },
            length: { minimum: 3, maximum: 20 }

  # Scopes
  scope :confirmed,      -> { where.not(confirmed_at: nil) }
  scope :trusted,        -> { where(trusted: true) }
  scope :newest,         -> { order(created_at: :desc) }
  scope :staff,          -> { where(['developer = :bool OR admin = :bool OR moderator = :bool', { bool: true }]) }
  scope :alphabetically, -> { order(username: :asc) }

  # Callbacks
  before_create do
    build_profile
    build_settings
  end

  class << self
    def find_first_by_auth_conditions(warden_conditions)
      conditions = warden_conditions.dup
      if login = conditions.delete(:login)
        where(conditions).where(['lower(username) = lower(:login) OR lower(email) = lower(:login)', { login: login }]).first
      else
        where(conditions).first
      end
    end

    def find_by_username!(username)
      user = where(['lower(username) = lower(?)', username]).first

      raise ActiveRecord::RecordNotFound, "Couldn't find User with username=#{username}" if user.blank?

      user
    end

    def ensure_consistency!
      connection.execute('
        UPDATE users SET comments_count = (
          SELECT COUNT(*) FROM comments WHERE comments.commentable_type = \'User\' AND comments.commentable_id = users.id
        )
      ')
    end
  end

  def to_param
    username
  end

  def settings
    super || build_settings
  end

  def profile
    super || build_profile
  end

  module AuthenticationTokenMethods
    def self.included(base)
      base.class_eval do
        before_save :ensure_authentication_token
      end
    end

    def reset_authentication_token
      self.authentication_token = generate_authentication_token
    end

    def reset_authentication_token!
      reset_authentication_token
      save validate: false
    end

    def ensure_authentication_token
      reset_authentication_token if authentication_token.blank?
    end

    def ensure_authentication_token!
      reset_authentication_token! if authentication_token.blank?
    end

    def generate_authentication_token
      loop do
        token = Devise.friendly_token
        break token unless self.class.where(authentication_token: token).exists?
      end
    end
    private :generate_authentication_token
  end

  module RoleMethods
    def role_name
      return 'Developer' if developer?
      return 'Admin'     if admin?
      return 'Moderator' if moderator?
      'Member'
    end

    def staff?
      developer? || admin? || moderator?
    end
  end

  module SubscriptionMethods
    def subscribed_to?(subscribable)
      subscriptions.where(subscribable: subscribable).exists?
    end

    def subscribed_wallpapers_by_subscribable_type(subscribable_type)
      subscription_ids_rel = subscriptions.select(:id)
                                          .where(subscribable_type: subscribable_type)

      wallpaper_ids_rel = SubscriptionsWallpaper.select(:wallpaper_id)
                                                .where(subscription_id: subscription_ids_rel)

      Wallpaper.where(id: wallpaper_ids_rel)
    end

    def followings_count
      user_subscriptions.count
    end

    def followers_count
      subscribers.count
    end
  end

  module FavouritingMethods
    def favourited?(wallpaper)
      favourites.where(wallpaper: wallpaper).exists?
    end

    def favourite(wallpaper)
      favourites.create(wallpaper: wallpaper)
    end

    def unfavourite(wallpaper)
      favourites.where(wallpaper: wallpaper).first.try(:destroy)
    end

    def favourites_count
      favourites.count
    end
  end

  module CollectionMethods
    def collections_count
      collections.count
    end

    def public_collections_count
      collections.where(public: true).count
    end
  end

  include AuthenticationTokenMethods
  include RoleMethods
  include SubscriptionMethods
  include FavouritingMethods
  include CollectionMethods
end
