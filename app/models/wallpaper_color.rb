# == Schema Information
#
# Table name: wallpaper_colors
#
#  id           :integer          not null, primary key
#  wallpaper_id :integer
#  color_id     :integer
#  percentage   :float
#
# Indexes
#
#  index_wallpaper_colors_on_color_id      (color_id)
#  index_wallpaper_colors_on_wallpaper_id  (wallpaper_id)
#

class WallpaperColor < ActiveRecord::Base
  belongs_to :wallpaper
  belongs_to :color, class_name: 'Kolor'

  delegate :red, :green, :blue, :hex, :to_html_hex, to: :color
end
