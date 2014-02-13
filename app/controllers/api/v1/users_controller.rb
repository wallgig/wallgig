class Api::V1::UsersController < Api::V1::BaseController
  def index
    @users = User.includes(:profile)

    if params[:usernames].present?
      @users = @users.where('LOWER(username) IN (?)', params[:usernames].split(',').map(&:strip).map(&:downcase))
    else
      @users = @users.page(params[:page])
    end

    if params[:includes].present?
      @includes = params[:includes].split(',').map(&:strip)
    else
      @includes = ['basic']
    end
  end

  def me
    respond_with current_user
  end
end