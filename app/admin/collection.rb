ActiveAdmin.register Collection do
  config.filters = false

  menu parent: 'Wallpapers'

  permit_params :name, :public

  scope :all, default: true
  scope :public
  scope :private

  index do
    selectable_column
    id_column
    column :name
    column(:public, sortable: :public) { |c| status_tag c.public? ? 'Yes' : 'No' }
    column(:wallpapers_count) { |c| c.wallpapers.size }
    column 'Views', :impressions_count
    column :owner
    column :created_at
    column :updated_at
    actions
  end

  show do
    panel 'Collection Details' do
      attributes_table_for collection do
        row :name
        row :public
        row :owner
        row :impressions_count
        row(:wallpapers_count) { |c| c.wallpapers.count }
        row :created_at
        row :updated_at
      end
    end
    active_admin_comments
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :public
    end
    f.actions
  end

  controller do
    def scoped_collection
      Collection.includes(:owner)
    end
  end
end
