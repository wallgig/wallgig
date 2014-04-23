class AddNewWindowToUserSettings < ActiveRecord::Migration
  def change
    add_column :user_settings, :new_window, :boolean, null: false, default: true
  end
end
