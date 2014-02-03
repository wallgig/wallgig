class AddLastCommentedAtAndLastCommentedByToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :last_commented_at, :datetime
    add_reference :topics, :last_commented_by, index: true
  end
end
