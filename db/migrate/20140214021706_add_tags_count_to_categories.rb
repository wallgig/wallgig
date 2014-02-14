class AddTagsCountToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :tags_count, :integer
  end
end
