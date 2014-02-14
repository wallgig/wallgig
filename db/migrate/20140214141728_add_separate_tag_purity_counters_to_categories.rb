class AddSeparateTagPurityCountersToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :sfw_tags_count, :integer, default: 0
    add_column :categories, :sketchy_tags_count, :integer, default: 0
    add_column :categories, :nsfw_tags_count, :integer, default: 0
    remove_column :categories, :tags_count, :integer, default: 0
  end
end
