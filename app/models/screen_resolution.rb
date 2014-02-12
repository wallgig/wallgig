# == Schema Information
#
# Table name: screen_resolutions
#
#  id       :integer          not null, primary key
#  width    :integer
#  height   :integer
#  category :string(255)
#

class ScreenResolution < ActiveRecord::Base
  extend Enumerize
  enumerize :category, in: [:standard, :widescreen]

  default_scope -> { order("case when category = 'widescreen' then 1 else 2 end ASC, width DESC, height DESC") }

  def self.group_by_category_for_index
    Rails.cache.fetch('screen_resolution_group_by_category_for_index', expires_in: 1.day) do
      self.all.to_a
              .map      { |sr| sr.serializable_hash(only: [:width, :height], methods: :category_text).with_indifferent_access }
              .group_by { |sr| sr[:category_text] }
    end
  end

  def to_s
    "#{width}&times;#{height}".html_safe
  end

  def to_geometry_s
    "#{width}x#{height}"
  end

  def wallpapers
    @wallpapers ||= Wallpaper.where(image_width: width, image_height: height)
  end
end