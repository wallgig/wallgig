class TopicsController < ApplicationController
  before_action :set_forums
  before_action :set_owner, only: [:new, :create]
  before_action :set_topic
  before_action :authenticate_user!, only: [:new, :create]

  layout 'forum'

  def show
    @comments = @topic.comments.page
    @comments = @comments.page(params[:page] || @comments.total_pages) # Show last page first
  end

  def new
    @topic = @owner.present? ? @owner.topics.new : Topic.new
    @topic.user = current_user
    authorize! :create, @topic
  end

  def create
    @topic = (@owner.present? ? @owner.topics : Topic).new(topic_params)
    @topic.user = current_user
    authorize! :create, @topic

    respond_to do |format|
      if @topic.save
        format.html { redirect_to @topic, notice: 'Topic was successfully created.' }
        format.json { render action: 'show', status: :created, location: @topic }
      else
        format.html { render action: 'new' }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_forums
    @forums = Forum.accessible_by(current_ability, :read).ordered
  end

  def set_owner
    if params[:forum_id].present?
      @owner = Forum.friendly.find(params[:forum_id])
      authorize! :read, @owner
    end
  end

  def set_topic
    @topic = (@owner.present? ? @owner.topics : Topic).find(params[:id])
    authorize! :read, @topic
  end

  def topic_params
    params.require(:topic).permit(:title, :content)
  end
end
