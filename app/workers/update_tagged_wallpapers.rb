class UpdateTaggedWallpapers
  include Sidekiq::Worker

  def perform(tag_id)
    Tag.find(tag_id).update_tagged_wallpapers
  end

end
