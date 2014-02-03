class TopicsController < ApplicationController
  before_action :set_forums
  before_action :set_postable_forums, only: [:new, :create]
  before_action :set_topic, except: [:new, :create]
  before_action :authenticate_user!, only: [:new, :create]

  layout 'forum'

  def show
    @comments = @topic.comments.page
    @comments = @comments.page(params[:page] || @comments.total_pages) # Show last page first
  end

  def new
    @topic = current_user.topics.new
    @topic.forum = @forums.friendly.find(params[:forum]) if params[:forum].present?
    authorize! :create, @topic
  end

  def create
    @topic = current_user.topics.new(topic_params)
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

  Topic::MODERATION_ACTIONS.each do |action|
    define_method action do
      authorize! :moderate, @topic
      @topic.send("#{action.to_s}!")

      respond_to do |format|
        format.html { redirect_to @topic, notice: "#{action.to_s.capitalize} action performed on topic." }
        format.json { head :no_content }
      end
    end
  end

  private

  def set_forums
    @forums = Forum.accessible_by(current_ability, :read).ordered
  end

  def set_postable_forums
    @postable_forums = Forum.accessible_by(current_ability, :post).ordered
  end

  def set_topic
    @topic = Topic.find(params[:id])
    authorize! :read, @topic
  end

  def topic_params
    params.require(:topic).permit(:title, :content, :forum_id)
  end
end
