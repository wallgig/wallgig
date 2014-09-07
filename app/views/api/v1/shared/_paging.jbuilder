json.paging do
  json.extract! collection, :current_page, :total_pages, :total_count

  json.self url_for(page: collection.current_page, format: :json, only_path: false)

  unless collection.last_page?
    json.next url_for(
      page: collection.next_page,
      format: :json,
      only_path: false
    )
  end

  unless collection.first_page?
    json.previous url_for(
      page: collection.previous_page,
      format: :json,
      only_path: false
    )
  end
end
