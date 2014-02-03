module ForumLayout
  extend ActiveSupport::Concern
  included do
    before_action :set_forum_list
    layout 'forum'
  end

  def set_forum_list
    @forum_list = Rails.cache.fetch(['forum_list', current_ability], expires_in: 1.hour) do
      Forum.accessible_by(current_ability, :read).ordered
    end
  end
end
