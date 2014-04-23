class FixBooleansInUserSettings < ActiveRecord::Migration
  def change
    [:sfw, :sketchy, :nsfw, :infinite_scroll, :invisible].each do |column_name|
      change_column_null :user_settings, column_name, false
    end
  end
end
