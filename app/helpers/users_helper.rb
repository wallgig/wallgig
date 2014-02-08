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

  def user_avatar_url(user, size = 200)
    avatar = user.profile.avatar
    if avatar.present?
      avatar.thumb("#{size}x#{size}#").url
    else
      gravatar_url(user, size)
    end
  end
end
