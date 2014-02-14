class WallpaperMergerService
  def initialize(from_wallpaper, to_wallpaper)
    @from_wallpaper = from_wallpaper
    @to_wallpaper = to_wallpaper
  end

  def execute
    Wallpaper.transaction do
      @to_wallpaper.source ||= @from_wallpaper.source

      merge_tags
      merge_comments
      merge_favourites
      merge_impressions

      @from_wallpaper.destroy

      @to_wallpaper.save
    end
  end

  private

  def merge_tags
    from_tag_ids = @from_wallpaper.wallpapers_tags.pluck(:tag_id)
    to_tag_ids   = @to_wallpaper.wallpapers_tags.pluck(:tag_id)

    tags_ids_to_add = from_tag_ids - to_tag_ids
    tags_ids_to_add.each do |tag_id|
      @to_wallpaper.wallpapers_tags.create!(tag_id: tag_id)
    end
  end

  def merge_comments
    Comment.where(commentable: @from_wallpaper).update_all(commentable_id: @to_wallpaper.id)
  end

  def merge_favourites
    from_user_ids = @from_wallpaper.votes.up.by_type(User)
    to_user_ids   = @to_wallpaper.votes.up.by_type(User)

    user_ids_to_add = from_user_ids - to_user_ids
    User.find(user_ids_to_add).each do |user|
      @to_wallpaper.liked_by user
    end
  end

  def merge_impressions
    Impression.where(impressionable: @from_wallpaper).update_all(impressionable_id: @to_wallpaper.id)
  end
end