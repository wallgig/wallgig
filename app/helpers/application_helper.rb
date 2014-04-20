module ApplicationHelper
  ALERT_TYPES = [:danger, :info, :success, :warning]

  def bootstrap_flash
    flash_messages = []
    flash.each do |type, message|
      # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
      next if message.blank?
      
      type = :success if type == :notice
      type = :danger  if type == :alert
      next unless ALERT_TYPES.include?(type)

      Array(message).each do |msg|
        text = content_tag(:div,
                           content_tag(:button, raw("&times;"), :class => "close", "data-dismiss" => "alert") +
                           msg.html_safe, :class => "alert fade in alert-#{type}")
        flash_messages << text if msg
      end
    end
    flash_messages.join("\n").html_safe
  end

  def gravatar_url(user, size=200)
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    "http://gravatar.com/avatar/#{gravatar_id}.png?d=identicon&s=#{size}"
  end

  def irc_url(user=nil)
    url = "https://qchat.rizon.net/?channels=wallgig&prompt=1"
    url << "&nick=#{user.username.parameterize}" if user.present?
    url
  end

  # Taken from http://icelab.com.au/articles/render-single-line-markdown-text-with-redcarpet/
  def markdown(text)
    return if text.blank?

    renderer = Redcarpet::Render::HTML.new({
      :filter_html => true,
      :hard_wrap => true
    })
    markdown = Redcarpet::Markdown.new(renderer, {
      :autolink => true,
      :no_intra_emphasis => true
    })

    markdown.render(text).html_safe
  end

  def markdown_line(text)
    return if text.blank?

    renderer = Redcarpet::Render::HTMLWithoutBlockElements.new({
      :filter_html => true,
      :hard_wrap => true
    })
    markdown = Redcarpet::Markdown.new(renderer, {
      :autolink => true,
      :no_intra_emphasis => true
    })

    markdown.render(text).html_safe
  end

  def time_ago_tag(date_or_time, options = {})
    options.reverse_merge!({
      data: { provide: 'time-ago' },
      title: date_or_time.getutc.iso8601
    })

    time_tag(date_or_time, options)
  end

  def fa_icon_tag(icon)
    "<span class='fa fa-#{icon}'></span>".html_safe
  end

  #
  # Kaminari overrides
  #

  # Searchkick doesn't have the `last_page?` method
  def link_to_next_page(scope, name, options = {}, &block)
    params = options.delete(:params) || {}
    param_name = options.delete(:param_name) || Kaminari.config.param_name
    link_to_unless scope.current_page >= scope.total_pages, name, params.merge(param_name => scope.next_page), options.reverse_merge(:rel => 'next') do
      block.call if block
    end
  end
end
