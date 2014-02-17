class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :user, index: true
      t.references :notifiable, polymorphic: true, index: true
      t.text :message
      t.boolean :read, null: false, default: false

      t.timestamps
    end
  end
end
