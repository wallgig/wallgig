class AddReadIndexToNotifications < ActiveRecord::Migration
  def change
    add_index :notifications, :read
  end
end
