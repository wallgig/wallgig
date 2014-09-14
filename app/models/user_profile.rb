# == Schema Information
#
# Table name: user_profiles
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  cover_wallpaper_id       :integer
#  cover_wallpaper_y_offset :integer
#  country_code             :string(2)
#  created_at               :datetime
#  updated_at               :datetime
#  username_color_hex       :string(255)
#  title                    :string(255)
#  avatar_uid               :string(255)
#
# Indexes
#
#  index_user_profiles_on_cover_wallpaper_id  (cover_wallpaper_id)
#  index_user_profiles_on_user_id             (user_id) UNIQUE
#

class UserProfile < ActiveRecord::Base
  AVATAR_SIZES = [20, 25, 30, 40, 50, 100, 200]

  belongs_to :user
  belongs_to :cover_wallpaper, class_name: 'Wallpaper'

  dragonfly_accessor :avatar
  validates_size_of :avatar,     maximum: 5.megabytes
  validates_property :mime_type, of: :avatar, in: ['image/jpeg', 'image/png', 'image/gif']
  validates_property :width,     of: :avatar, in: (50..500)
  validates_property :height,    of: :avatar, in: (50..500)

  validates :country_code, inclusion: { in: ISO3166::Country::Names.map { |_, code| code }, allow_blank: true }

  before_save :nilify_cover_wallpaper_y_offset, if: :cover_wallpaper_id_changed?

  def nilify_cover_wallpaper_y_offset
    self.cover_wallpaper_y_offset = nil
  end

  def cover_style
    # OPTIMIZE
    styles = []
    if cover_wallpaper.present? && cover_wallpaper.sfw?
      styles << "background-image: url(#{cover_wallpaper.image.thumb('2000x350#').url})"
    else
      styles << "background-image: url(http://placekitten.com/1920/450)"
    end
    styles.join ';'
  end

  def username_color_hex=(value)
    write_attribute :username_color_hex, Kolor.normalize_html_hex(value).presence
  end

  def title=(value)
    write_attribute :title, value.presence
  end

  # Check if we need to detect this User's country code
  # User can hide his/her country by setting the country code to an empty string ""
  def needs_country_code?
    country_code.nil?
  end

  def country_name
    ISO3166::Country.find_country_by_alpha2(country_code).names.first if country_code.present?
  end
end
