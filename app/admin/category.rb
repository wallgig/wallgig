ActiveAdmin.register Category do
  config.filters = false

  menu parent: 'Tags'

  permit_params :name, :slug, :parent_id

  index do
    selectable_column
    column :name
    column :slug
    column('Parent') { |category| category.parent.name if category.parent.present? }
    column :sfw_tags_count
    column :sketchy_tags_count
    column :nsfw_tags_count
    actions do |category|
      link_to 'Tags', admin_tags_path(q: { category_id_eq: category.id })
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :slug
      f.input :parent_id, collection: Category.arrange_as_array({ order: 'name' }, f.object.possible_parents), label_method: :name_for_selects, value_method: :id, include_blank: true
    end
    f.actions
  end

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end
end
