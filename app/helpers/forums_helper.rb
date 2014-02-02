module ForumsHelper
  def css_styles_for_forum(forum)
    styles = ''
    styles << "background-color: ##{forum.color};" if forum.color.present?
    styles << "color: ##{forum.text_color}"        if forum.text_color.present?
    styles
  end
end
