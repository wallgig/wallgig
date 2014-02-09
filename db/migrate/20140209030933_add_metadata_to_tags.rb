class AddMetadataToTags < ActiveRecord::Migration
  def change
    add_column :tags, :slug, :string
    add_index :tags, :slug, unique: true
    add_reference :tags, :category, index: true
    add_column :tags, :purity, :string
    add_index :tags, :purity
    add_reference :tags, :coined_by, index: true
    add_reference :tags, :approved_by, index: true
    add_column :tags, :approved_at, :datetime
  end
end
