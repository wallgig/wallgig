class WallpaperDecorator < Draper::Decorator
  delegate_all

  def requested_image
    return if image.blank?
    return resized_image if resized_image.present?
    image
  end

  def requested_image_url
    return if image.blank?
    return resized_image.url if resized_image.present?

    if Rails.env.production?
      "#{ENV['CDN_HOST']}#{image.remote_url}"
    else
      image.url
    end
  end

  def path_with_requested_image_resolution
    if requested_image_resolution == original_image_resolution
      h.wallpaper_path(self)
    else
      h.resized_wallpaper_path(self, width: requested_image_resolution.width, height: requested_image_resolution.height)
    end
  end

  def thumbnail_image_url
    return if thumbnail_image.blank?
    if Rails.env.production?
      "#{ENV['CDN_HOST']}#{thumbnail_image.remote_url}"
    else
      thumbnail_image.url
    end
  end

  def thumbnail_image_tag
    h.image_tag(thumbnail_image_url, width: 250, height: 188, alt: to_s)
  end

  # Public: Renders wallpaper thumbnail link tag.
  # Link opens in a new window if 'current_settings.new_window' is set to true.
  #
  # wallpaper - Wallpaper model object
  # options - HTML attribute options hash
  #   :lazy - Use lazy loading (default: true)
  #   :new_window - Open links in new window
  #
  # Examples
  #
  #   thumbnail_link_to_wallpaper(@wallpaper)
  #
  #   thumbnail_link_to_wallpaper(@wallpaper, lazy: true)
  #
  def thumbnail_link(options={})
    link_html_options = {}
    link_html_options[:title] = tag_list_text.presence || to_s
    link_html_options[:target] = '_blank' if options[:new_window]

    h.link_to path_with_requested_image_resolution, link_html_options do
      if options[:lazy]
        h.image_tag(
          nil,
          width: Wallpaper::THUMBNAIL_WIDTH,
          height: Wallpaper::THUMBNAIL_HEIGHT,
          class: 'img-wallpaper lazy',
          data: {
            src: thumbnail_image_url
          }
        )
      else
        h.image_tag(
          thumbnail_image_url,
          width: Wallpaper::THUMBNAIL_WIDTH,
          height: Wallpaper::THUMBNAIL_HEIGHT,
          class: 'img-wallpaper'
        )
      end
    end
  end

  def favourite_button_for_list
    options = {
      class: 'btn btn-sm pull-left',
      data: {
        remote: true,
        method: :post,
        url: h.toggle_favourite_wallpaper_path(wallpaper),
        action: 'favourite'
      }
    }
    options[:class] << ' btn-favourite favourited' if context[:favourited]

    h.content_tag :a, options do
      "<span class='fa fa-star'></span>" \
      "<span class='count'>#{favourites_count}</span>".html_safe
    end
  end

  def resolution_select_tag
    option_tags = h.grouped_options_for_select(
      resizable_resolutions.array_for_options,
      requested_image_resolution.to_param,
      prompt: "#{original_image_resolution} (Original)".html_safe
    )

    h.select_tag 'resolution',
                 option_tags,
                 class: 'form-control',
                 data: { action: 'resize', url: h.wallpaper_path(self) }
  end
end