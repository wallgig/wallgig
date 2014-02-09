ActiveAdmin.register ActsAsTaggableOn::Tag, as: 'Tag' do
  config.filters = false
  config.sort_order = 'name_asc'
end
