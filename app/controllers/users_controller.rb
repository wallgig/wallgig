class UsersController < ApplicationController
  before_action :set_user, except: :index

  impressionist actions: [:show]

  layout 'user_profile', except: :index

  # GET /users
  def index
    @users = User.confirmed
                 .where(created_at: 1.week.ago.beginning_of_day..Time.now.end_of_day)
                 .includes(:profile)
                 .newest
    @users_group_by_day = @users.group_by { |u| u.created_at.to_date }

    @staff_users = User.staff.includes(:profile).group_by { |u| u.role_name }
    @staff_users = [['Developers', @staff_users['Developer']], ['Admins', @staff_users['Admin']], ['Moderators', @staff_users['Moderator']]].reject { |u| u[1].blank? }

    @online_users = users_online.online_users
                                .includes(:profile)
  end

  # GET /users/1
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

    # Comments
    @comments = @user.comments.includes(:user).latest
  end

  # GET /users/1/following
  def following
    @following = @user.user_subscriptions.includes(:profile)
  end

  # GET /users/1/followers
  def followers
    @followers = @user.subscribers.includes(:profile)
  end

  private

  def set_user
    @user = User.find_by_username!(params[:id])
    authorize! :read, @user
  end
end
