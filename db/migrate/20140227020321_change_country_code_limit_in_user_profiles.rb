class ChangeCountryCodeLimitInUserProfiles < ActiveRecord::Migration
  def up
    change_column :user_profiles, :country_code, :string, limit: 2
  end

  def down
    change_column :user_profiles, :country_code, :string, limit: 255
  end
end
