ActiveAdmin.register Tag, as: 'Tag' do
  config.filters = false
  config.sort_order = 'name_asc'

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end
end
