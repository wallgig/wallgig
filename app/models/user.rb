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

class User < ActiveRecord::Base
  attr_accessor :login

  has_many :collections, dependent: :destroy

  has_many :wallpapers, dependent: :nullify
  # has_many :favourites, dependent: :destroy
  # has_many :favourite_wallpapers, -> { reorder('favourites.created_at DESC') }, through: :favourites, source: :wallpaper

  has_many :owned_groups, class_name: 'Group', foreign_key: 'owner_id'

  has_one :profile,  class_name: 'UserProfile', dependent: :destroy
  has_one :settings, class_name: 'UserSetting', dependent: :destroy

  has_many :topics, dependent: :nullify

  has_many :coined_tags, class_name: 'Tag', foreign_key: 'coined_by_id'

  has_many :subscriptions, dependent: :destroy
  include Subscribable

  has_many :notifications, dependent: :destroy

  # Include default devise modules. Others available are:
  # :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable

  acts_as_commentable

  acts_as_voter

  is_impressionable

  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: /\A[a-zA-Z0-9_]*[a-zA-Z][a-zA-Z0-9_]*\z/, message: 'Only letters, numbers, and underscores allowed.' },
            length: { minimum: 3, maximum: 20 }

  # Scopes
  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :trusted,   -> { where(trusted: true) }
  scope :newest,    -> { order(created_at: :desc) }
  scope :staff,     -> { where(['developer = :bool OR admin = :bool OR moderator = :bool', { bool: true }]) }

  # Callbacks
  before_save :ensure_authentication_token

  before_create do
    build_profile
    build_settings
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(['lower(username) = lower(:login) OR lower(email) = lower(:login)', { login: login }]).first
    else
      where(conditions).first
    end
  end

  def self.find_by_username!(username)
    user = where(['lower(username) = lower(?)', username]).first

    raise ActiveRecord::RecordNotFound, "Couldn't find User with username=#{username}" if user.blank?

    user
  end

  def self.ensure_consistency!
    connection.execute('
      UPDATE users SET comments_count = (
        SELECT COUNT(*) FROM comments WHERE comments.commentable_type = \'User\' AND comments.commentable_id = users.id
      )
    ')
  end

  def to_param
    username
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

  def settings
    super || build_settings
  end

  def profile
    super || build_profile
  end

  def favourite_wallpapers
    get_up_voted(Wallpaper)
  end

  def role_name
    return 'Developer' if developer?
    return 'Admin'     if admin?
    return 'Moderator' if moderator?
    'Member'
  end

  def staff?
    developer? || admin? || moderator?
  end

  def subscribed_to?(subscribable)
    subscriptions.where(subscribable: subscribable).exists?
  end

  def subscribed_wallpapers_by_subscribable_type(subscribable_type)
    Wallpaper.where(id: subscriptions.select(:subscribable_id)
                                     .where(subscribable_type: subscribable_type))
  end

  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless self.class.where(authentication_token: token).exists?
    end
  end
end
