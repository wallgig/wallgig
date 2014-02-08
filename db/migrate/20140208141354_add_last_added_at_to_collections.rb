class AddLastAddedAtToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :last_added_at, :datetime
  end
end
