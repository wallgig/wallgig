class RefactorPermissionsOfForums < ActiveRecord::Migration
  def change
    remove_column :forums, :guest_can_read, :boolean
    remove_column :forums, :guest_can_post, :boolean
    remove_column :forums, :guest_can_reply, :boolean
    remove_column :forums, :member_can_read, :boolean
    remove_column :forums, :member_can_post, :boolean
    remove_column :forums, :member_can_reply, :boolean
    add_column :forums, :can_read, :boolean, default: true
    add_column :forums, :can_post, :boolean, default: true
    add_column :forums, :can_comment, :boolean, default: true
  end
end
