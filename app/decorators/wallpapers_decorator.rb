class WallpapersDecorator < Draper::CollectionDecorator
  # Pagination
  delegate :total_count, :limit_value, :current_page, :total_pages, :next_page, :prev_page, :first_page?, :last_page?

  # Elasticsearch (searchkick)

  def facets
    return object.facets if object.respond_to?(:facets)
    {}
  end

  def link_to_next_page
    return unless has_pagination?
    h.link_to_next_page object, 'Next Page', class: 'btn btn-block btn-default btn-lg', params: context[:search_options]
  end

  def has_pagination?
    object.is_a?(Kaminari::PageScopeMethods) || object.is_a?(Searchkick::Results)
  end

  def ids
    object.map(&:id)
  end

  def current_user_favourited_wallpaper_ids
    @current_user_favourited_wallpaper_ids ||= begin
      if context[:current_user].present?
        context[:current_user].favourite_wallpapers.where(id: ids).pluck(:id)
      else
        []
      end
    end
  end

  protected
    def decorate_item(item)
      context_with_favourited = context.dup
      context_with_favourited[:favourited] = current_user_favourited_wallpaper_ids.include?(item.id)

      item_decorator.call(item, context: context_with_favourited)
    end

end