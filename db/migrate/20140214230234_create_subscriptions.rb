class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references :user, index: true
      t.references :subscribable, polymorphic: true, index: true
      t.datetime :last_visited_at

      t.timestamps
    end
  end
end
