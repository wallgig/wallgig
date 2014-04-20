class RemoveVotesFromWallpapers < ActiveRecord::Migration
  def change
    remove_column :wallpapers, :cached_votes_total, :integer
    remove_column :wallpapers, :cached_votes_score, :integer
    remove_column :wallpapers, :cached_votes_up, :integer
    remove_column :wallpapers, :cached_votes_down, :integer
    remove_column :wallpapers, :cached_weighted_score, :integer
  end
end
