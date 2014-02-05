class ForumsController < ApplicationController
  before_action :set_forum, only: [:show]

  include ForumLayout

  def index
    if params[:q].present?
      @topics = topics.search_topics_and_comments(params[:q])
    else
      @topics = topics.latest
    end
  end

  def show
    @topics = topics.pinned_first.latest
    render action: 'index'
  end

  private

  def set_forum
    @forum = Forum.friendly.find(params[:id])
    authorize! :read, @forum
  end

  def forum_params
    params.require(:forum).permit(:name, :slug, :description)
  end

  def topics
    topics = @forum.try(:topics) || Topic
    topics.accessible_by(current_ability, :read)
          .includes(:forum, user: :profile, last_commented_by: :profile)
          .page(params[:page])
  end
end
