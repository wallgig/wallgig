class AddInvisibleToUserSettings < ActiveRecord::Migration
  def change
    add_column :user_settings, :invisible, :boolean, default: false
  end
end
