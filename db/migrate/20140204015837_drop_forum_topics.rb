class DropForumTopics < ActiveRecord::Migration
  def up
    drop_table :forum_topics
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
