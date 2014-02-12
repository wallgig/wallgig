class WallpapersFavouriteStatusPopulator
  def initialize(wallpapers, user)
    @wallpapers = wallpapers
    @user = user
  end

  def wallpaper_ids
    @wallpapers.map(&:id)
  end

  def wallpapers
    return @wallpapers if @user.blank?

    @favourite_wallpaper_ids = @user.favourite_wallpapers.where(id: wallpaper_ids).pluck(:id)

    @wallpapers.each do |wallpaper|
      wallpaper.favourite_status = @favourite_wallpaper_ids.include?(wallpaper.id)
    end
  end
end
