# == Schema Information
#
# Table name: user_settings
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  sfw                  :boolean          default(TRUE)
#  sketchy              :boolean          default(FALSE)
#  nsfw                 :boolean          default(FALSE)
#  per_page             :integer          default(20)
#  infinite_scroll      :boolean          default(TRUE)
#  screen_width         :integer
#  screen_height        :integer
#  created_at           :datetime
#  updated_at           :datetime
#  screen_resolution_id :integer
#  invisible            :boolean          default(FALSE)
#  aspect_ratios        :text
#  resolution_exactness :string(255)      default("at_least")
#
# Indexes
#
#  index_user_settings_on_screen_resolution_id  (screen_resolution_id)
#  index_user_settings_on_user_id               (user_id) UNIQUE
#

class UserSetting < ActiveRecord::Base
  PURITY_KEYS        = [:sfw, :sketchy, :nsfw]
  PURITY_STRING_KEYS = ['sfw', 'sketchy', 'nsfw']

  extend Enumerize

  belongs_to :user
  belongs_to :screen_resolution

  enumerize :per_page, in: [20, 40, 60], default: 20

  serialize :aspect_ratios, Array
  enumerize :aspect_ratios, in: %w(1_33 1_25 1_77 1_60 1_70 2_50 3_20 1_01 0_99), multiple: true

  enumerize :resolution_exactness, in: [:at_least, :exactly], default: :at_least

  before_save :set_screen_resolution, if: proc { |s| s.screen_width_changed? || s.screen_height_changed? }

  validates :user, presence: true
  validates :per_page, presence: true
  validates :resolution_exactness, presence: true

  def purities
    out = []
    out << 'sfw'     if sfw?
    out << 'sketchy' if sketchy?
    out << 'nsfw'    if nsfw?
    out
  end

  def set_screen_resolution
    if screen_width.present? && screen_height.present?
      self.screen_resolution = ScreenResolution.where(width: screen_width, height: screen_height).first
    else
      self.screen_resolution = nil
    end
  end

  def needs_screen_resolution?
    screen_width.blank? || screen_height.blank?
  end

  def display_ads?
    true
  end
end
