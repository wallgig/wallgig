class AddColorAndTextColorToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :color, :string
    add_column :groups, :text_color, :string
  end
end
