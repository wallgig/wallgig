json.tags @tags do |tag|
  json.extract! tag, :id, :name, :purity, :category_name
end
