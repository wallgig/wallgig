class WallpaperDecorator < Draper::Decorator
  delegate_all

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