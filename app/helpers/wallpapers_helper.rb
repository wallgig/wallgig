module WallpapersHelper

  # Public: Renders wallpaper thumbnail link tag.
  # Link opens in a new window if 'current_settings.new_window' is set to true.
  #
  # wallpaper - Wallpaper model object
  # options - HTML attribute options hash
  #   :lazy - Use lazy loading (default: true)
  #
  # Examples
  # 
  #   thumbnail_link_to_wallpaper(@wallpaper)
  #   
  #   thumbnail_link_to_wallpaper(@wallpaper, lazy: true)
  #
  def thumbnail_link_to_wallpaper(wallpaper, options={})
    link_html_options = {}
    link_html_options[:title] = wallpaper.tag_list_text.presence || wallpaper.to_s
    link_html_options[:target] = '_blank' if current_settings.new_window?

    link_to wallpaper.path_with_resolution, link_html_options do
      if options[:lazy]
        image_tag nil, width: 250, height: 188, class: 'img-wallpaper lazy', data: { src: wallpaper.thumbnail_image_url }
      else
        image_tag wallpaper.thumbnail_image_url, width: 250, height: 188, class: 'img-wallpaper'
      end
    end
  end
end
