module TopicsHelper
  def icons_for_topic(topic)
    icons = ''
    icons << '<span class="glyphicon glyphicon-pushpin"></span>'   if topic.pinned?
    icons << '<span class="glyphicon glyphicon-lock"></span>'      if topic.locked?
    icons << '<span class="glyphicon glyphicon-eye-close"></span>' if topic.hidden?
    icons.html_safe
  end
end
