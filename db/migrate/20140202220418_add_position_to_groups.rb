class AddPositionToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :position, :integer
  end
end
