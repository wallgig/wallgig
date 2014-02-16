class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reportable, only: [:new, :create]

  def new
    @report = @reportable.reports.new
    @report.user = current_user
    authorize! :create, @report
  end

  def create
    @report = @reportable.reports.new(report_params)
    @report.user = current_user
    authorize! :create, @report

    respond_to do |format|
      if @report.save
        format.html { redirect_to root_url, notice: 'Report was successfully created.' }
        format.json { render status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_reportable
    if params[:comment_id].present?
      @reportable = Comment.find(params[:comment_id])
      authorize! :read, @reportable
    elsif params[:topic_id].present?
      @reportable = Topic.find(params[:topic_id])
      authorize! :read, @reportable
    elsif params[:wallpaper_id].present?
      @reportable = Wallpaper.find(params[:wallpaper_id])
      authorize! :read, @reportable
    end
  end

  def report_params
    params.require(:report).permit(:description)
  end
end
