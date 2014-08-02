json._page do
  json.extract! collection, :current_page, :total_pages, :total_count
end
