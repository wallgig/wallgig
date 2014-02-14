if @tag.present?
  json.tag do
    json.extract! @tag, :id, :name, :purity, :category_name
  end
else
  json.tag nil
end
