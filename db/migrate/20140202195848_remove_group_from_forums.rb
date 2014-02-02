class RemoveGroupFromForums < ActiveRecord::Migration
  def change
    remove_reference :forums, :group, index: true
  end
end
