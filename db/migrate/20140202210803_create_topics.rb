class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.references :owner, polymorphic: true, index: true
      t.references :user, index: true
      t.string :title
      t.text :content
      t.text :cooked_content
      t.boolean :pinned
      t.boolean :locked
      t.boolean :hidden

      t.timestamps
    end
  end
end
