class AddTrustedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :trusted, :boolean, default: false
  end
end
