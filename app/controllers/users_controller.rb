class UsersController < ApplicationController
  before_action :set_user, only: [:show]
  before_action :authenticate_user!, only: [:update_screen_resolution]

  impressionist actions: [:show]

  layout 'user_profile', only: :show

  def index
    @users = User.confirmed.where(created_at: 1.week.ago..Time.now).includes(:profile).newest
    @user_days = @users.group_by { |u| u.created_at.to_date }

    @user_staff = User.staff.includes(:profile).group_by { |u| u.role_name }
    @user_staff = [['Developers', @user_staff['Developer']], ['Admins', @user_staff['Admin']], ['Moderators', @user_staff['Moderator']]].reject { |u| u[1].blank? }
  end

  def show
    # Wallpapers
    @wallpapers = @user.wallpapers.accessible_by(current_ability, :read)
                                  .with_purities(current_purities)
                                  .latest
                                  .limit(6)
    @wallpapers = WallpapersDecorator.new(@wallpapers, context: { current_user: current_user })

    # Favourite wallpapers
    @favourite_wallpapers = @user.favourite_wallpapers.accessible_by(current_ability, :read)
                                                      .with_purities(current_purities)
                                                      .latest
                                                      .limit(10)
    @favourite_wallpapers = WallpapersDecorator.new(@favourite_wallpapers, context: { current_user: current_user })

    # Collections
    @collections = @user.collections.latest
                                    .accessible_by(current_ability, :read)
                                    .limit(6)
    if myself?
      @collections = @collections.not_empty
    else
      @collections = @collections.not_empty_for_purities(current_purities)
    end
  end

  # TODO move this under account namespace
  def update_screen_resolution
    width  = params.require(:width)
    height = params.require(:height)
    current_settings.update(screen_width: width, screen_height: height)

    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { head :no_content }
    end
  end

  private

  def set_user
    @user = User.find_by_username!(params[:id])
    authorize! :read, @user
  end
end
