module ForumsHelper
  def css_styles_for_forum(forum, swap = false)
    props = ['background-color', 'color']
    props.reverse! if swap
    styles = ''
    styles << "#{props[0]}:##{forum.color};"     if forum.color.present?
    styles << "#{props[1]}:##{forum.text_color};" if forum.text_color.present?
    styles
  end
end
