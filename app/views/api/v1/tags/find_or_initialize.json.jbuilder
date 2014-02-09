if @tag.present?
  json.tag do
    json.extract! @tag, :id, :name, :purity, :category_name
  end
else
  json.tag nil
end

if @available_categories.present?
  json.available_categories @available_categories do |category|
    json.extract! category, :id
    json.label category.name_for_selects
  end
end
