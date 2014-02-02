class AddInternalToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :internal, :boolean, default: false
  end
end
