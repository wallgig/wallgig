class WallpapersDecorator < Draper::CollectionDecorator
  # pagination
  delegate :total_count, :limit_value, :current_page, :total_pages, :next_page, :prev_page, :first_page?, :last_page?

  def facets
    object.kind_of?(Tire::Results::Collection) ? object.facets : []
  end

  def link_to_next_page
    return unless has_pagination?
    h.link_to_next_page object, 'Next Page', class: 'btn btn-block btn-default btn-lg', params: context[:search_options]
  end

  def has_pagination?
    object.kind_of?(Kaminari::PageScopeMethods) || object.kind_of?(Tire::Results::Pagination)
  end

  protected
    def decorate_item(item)
      item_decorator.call(item, context: context)
    end

end