module UsersHelper
  def link_to_user(user, &block)
    if block_given?
      link_to user, class: ['link-user', css_class_for(user)], style: css_style_for_user(user), &block
    else
      link_to user.username, user, class: ['link-user', css_class_for(user)], style: css_style_for_user(user)
    end
  end

  def username_tag(user)
    content_tag :span, user.username, class: css_class_for(user), style: css_style_for_user(user)
  end

  def css_class_for(user)
    if user.developer?
      'user-developer'
    elsif user.admin?
      'user-admin'
    elsif user.moderator?
      'user-moderator'
    end
  end

  def css_style_for_user(user)
    "color:##{user.profile.username_color_hex};" if user.profile.username_color_hex.present?
  end

  def role_name_for(user)
    user.profile.title.presence || user.role_name
  end

  def user_avatar_url(user, size = nil)
    if size.present?
      size = size.to_i
      size = nil unless UserProfile::AVATAR_SIZES.include?(size)
    end
    size ||= 200

    avatar = user.profile.avatar
    if avatar.present?
      avatar.thumb("#{size}x#{size}#").url
    else
      gravatar_url(user, size)
    end
  end

  def user_online_status_tag(user)
    '<span class="icon-user-online"></span>'.html_safe if users_online.online?(user)
  end

  def flag_tag_for(user)
    return if user.profile.country_code.blank?
    content_tag :span, nil, class: "flag flag-#{user.profile.country_code.downcase}", data: { country: user.profile.country_name }
  end

  # Public: Renders user avatar image tag.
  #
  # user - User model object
  # options - HTML attribute options hash
  #   :size - Integer size of avatar (optional)
  #   :alt - (default: user's username)
  #   :class - CSS class (default: 'user-avatar')
  #
  # Examples
  # 
  #   user_avatar_tag(@user)
  #   
  #   user_avatar_tag(@user, size: 40)
  #
  def user_avatar_tag(user, options={})
    options = options.symbolize_keys
    options[:alt] ||= user.username
    options[:class] = Array.wrap(options[:class]) # ensure array
    options[:class] << 'user-avatar' # append 'user-avatar' CSS class

    image_tag(user_avatar_url(user, options[:size]), options)
  end
end
