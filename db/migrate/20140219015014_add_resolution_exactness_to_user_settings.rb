class AddResolutionExactnessToUserSettings < ActiveRecord::Migration
  def change
    add_column :user_settings, :resolution_exactness, :string, default: 'at_least'
  end
end
