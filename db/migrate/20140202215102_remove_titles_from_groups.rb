class RemoveTitlesFromGroups < ActiveRecord::Migration
  def change
    remove_column :groups, :admin_title, :string
    remove_column :groups, :moderator_title, :string
    remove_column :groups, :member_title, :string
  end
end
