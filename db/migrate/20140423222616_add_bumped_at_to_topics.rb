class AddBumpedAtToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :bumped_at, :datetime
  end
end
