module ApplicationHelper
  ALERT_TYPES = [:danger, :info, :success, :warning]

  def link_to(name = nil, options = nil, html_options = nil, &block)
    html_options, options, name = options, name, block if block_given?
    options ||= {}

    html_options = convert_options_to_data_attributes(options, html_options)

    url = url_for(options)
    html_options['href'] ||= url
    html_options['target'] ||= '_self'

    content_tag(:a, name || url, html_options, &block)
  end

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

end
