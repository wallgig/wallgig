class Api::V1::CollectionsController < Api::V1::BaseController
  before_action :set_user, only: [:index]

  # GET /api/v1/users/:user_id/collections
  def index
    @collections = @user.collections.ordered
  end

  private

  def set_user
    if params[:user_id] == 'me'
      @user = current_user
    else
      @user = User.find_by_username!(params[:user_id])
    end
    authorize! :read, @user
  end
end
