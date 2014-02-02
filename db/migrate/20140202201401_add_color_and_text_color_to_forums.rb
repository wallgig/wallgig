class AddColorAndTextColorToForums < ActiveRecord::Migration
  def change
    add_column :forums, :color, :string
    add_column :forums, :text_color, :string
  end
end
