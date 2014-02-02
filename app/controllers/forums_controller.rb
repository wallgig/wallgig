class ForumsController < ApplicationController
  before_action :set_forums
  before_action :set_forum, only: [:show]

  layout 'forum'

  def index
    @topics = Topic.accessible_by(current_ability, :read).for_index
  end

  def show
    @topics = @forum.topics.accessible_by(current_ability, :read).for_index
    render action: 'index'
  end

  private

  def set_forums
    @forums = Forum.accessible_by(current_ability, :read).ordered
  end

  def set_forum
    @forum = Forum.friendly.find(params[:id])
    authorize! :read, @forum
  end

  def forum_params
    params.require(:forum).permit(:name, :slug, :description)
  end
end
