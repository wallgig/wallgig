class WallpaperMergerService
  def initialize(from_wallpaper, to_wallpaper)
    @from_wallpaper = from_wallpaper
    @to_wallpaper = to_wallpaper
  end

  def execute
    Wallpaper.transaction do
      @to_wallpaper.source ||= @from_wallpaper.source

      move_tags
      move_comments
      move_favourites
      move_impressions
      move_collections_wallpapers

      @from_wallpaper.destroy

      @to_wallpaper.save
    end
  end

  private

  def move_tags
    from_tag_ids = @from_wallpaper.wallpapers_tags.pluck(:tag_id)
    to_tag_ids   = @to_wallpaper.wallpapers_tags.pluck(:tag_id)

    tag_ids_to_move = from_tag_ids - to_tag_ids

    @from_wallpaper.wallpapers_tags
      .where(tag_id: tag_ids_to_move)
      .update_all(wallpaper_id: @to_wallpaper.id)
  end

  def move_comments
    @from_wallpaper.comments.update_all(commentable_id: @to_wallpaper.id)
  end

  def move_favourites
    from_voter_ids = @from_wallpaper.votes.up.by_type(User).pluck(:voter_id)
    to_voter_ids   = @to_wallpaper.votes.up.by_type(User).pluck(:voter_id)

    voter_ids_to_move = from_voter_ids - to_voter_ids

    @from_wallpaper.votes.up.by_type(User)
      .where(voter_id: voter_ids_to_move)
      .update_all(votable_id: @to_wallpaper.id)
  end

  def move_impressions
    @from_wallpaper.impressions.update_all(impressionable_id: @to_wallpaper.id)
  end

  def move_collections_wallpapers
    from_collection_ids = @from_wallpaper.collections_wallpapers.pluck(:collection_id)
    to_collection_ids   = @to_wallpaper.collections_wallpapers.pluck(:collection_id)

    collection_ids_to_move = from_collection_ids - to_collection_ids

    @from_wallpaper.collections_wallpapers
      .where(collection_id: collection_ids_to_move)
      .update_all(wallpaper_id: @to_wallpaper.id)
  end
end