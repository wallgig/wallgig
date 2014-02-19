class AddAspectRatiosToUserSettings < ActiveRecord::Migration
  def change
    add_column :user_settings, :aspect_ratios, :text
  end
end
