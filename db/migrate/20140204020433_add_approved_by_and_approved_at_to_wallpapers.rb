class AddApprovedByAndApprovedAtToWallpapers < ActiveRecord::Migration
  def change
    add_reference :wallpapers, :approved_by, index: true
    add_column :wallpapers, :approved_at, :datetime
    add_index :wallpapers, :approved_at
  end
end
