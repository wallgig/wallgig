class CommentsController < ApplicationController
  before_action :set_parent
  before_action :set_comment, only: [:edit, :update, :destroy]
  before_action :authenticate_user!, only: :create

  def index
    if @parent.present?
      render partial: partial_name, collection: @parent.comments.recent, as: :comment
    else
      @comments = Comment.includes(:commentable).latest.page(params[:page])
    end
  end

  def edit
    authorize! :update, @comment
  end

  def create
    @comment = @parent.comments.new(comment_params)
    @comment.user = current_user

    authorize! :create, @comment

    if @comment.save
      # OPTIMIZE
      if @comment.commentable_type == 'Topic'
        redirect_to topic_path(@parent, anchor: "comment_#{@comment.id}"), notice: 'Comment was successfully created.'
      else
        render partial: partial_name, locals: { comment: @comment }
      end
    else
      if request.xhr?
        render json: @comment.errors.full_messages, status: :unprocessable_entity
      else
        render action: 'new'
      end
    end
  end

  def update
    authorize! :update, @comment

    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to actual_comment_url(@comment), notice: 'Comment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @parent.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize! :destroy, @comment
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to @comment.commentable, notice: 'Comment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_parent
    if params[:wallpaper_id].present?
      @parent = Wallpaper.find(params[:wallpaper_id])
    elsif params[:user_id].present?
      @parent = User.find_by(username: params[:user_id])
    elsif params[:topic_id].present?
      @parent = Topic.find(params[:topic_id])
      authorize! :comment, @parent # TODO authorize comment others too?
    end
    authorize! :read, @parent
  end

  def set_comment
    @comment = Comment.find(params[:id])
    authorize! :read, @comment
  end

  def comment_params
    params.require(:comment).permit(:comment)
  end

  def partial_name
    if @parent.is_a?(Wallpaper)
      'wallpaper_comment'
    else
      'comment'
    end
  end

  def actual_comment_url(comment)
    if comment.commentable_type == 'Topic'
      comment.commentable
    else
      comment
    end
  end
end
