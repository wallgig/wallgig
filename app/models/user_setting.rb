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
#

class UserSetting < ActiveRecord::Base
  extend Enumerize

  belongs_to :user
  belongs_to :screen_resolution

  enumerize :per_page, in: [20, 40, 60], default: 20

  serialize :aspect_ratios, Array
  enumerize :aspect_ratios, in: %w(1_33 1_25 1_77 1_60 1_70 2_50 3_20 1_01 0_99), multiple: true

  before_save :set_screen_resolution, if: proc { |s| s.screen_width_changed? || s.screen_height_changed? }

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
