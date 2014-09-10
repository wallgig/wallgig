class ApplicationController < ActionController::Base
  class AccessDenied < CanCan::AccessDenied; end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  helper UsersHelper
  helper_method :last_deploy_time
  helper_method :current_profile
  helper_method :current_settings
  helper_method :myself?

  rescue_from AccessDenied,         with: :access_denied_response
  rescue_from CanCan::AccessDenied, with: :access_denied_response

  protected

  def authenticate_admin_user!
    raise AccessDenied unless current_user.try(:admin?) || current_user.try(:moderator?)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:email, :password, :password_confirmation, :current_password) }
  end

  def last_deploy_time
    @last_deploy_time ||= File.new(Rails.root.join('last_deploy')).atime rescue nil
  end

  def current_profile
    @current_profile ||= begin
      if user_signed_in?
        current_user.profile
      else
        UserProfile.new
      end
    end
  end

  def current_settings
    @current_settings ||= begin
      if user_signed_in?
        current_user.settings
      else
        UserSetting.new
      end
    end
  end

  def myself?(user = nil)
    user ||= @user
    user_signed_in? && user.present? && user.class.name == 'User' && current_user.id == user.id
  end

  def access_denied_response(exception)
    respond_to do |format|
      format.html { redirect_to root_url, alert: exception.message }
      format.json do
        response = {
          error: {
            message: exception.message
          }
        }
        render json: response, status: :unauthorized
      end
    end
  end

  # TODO refactor
  module PurityMethods
    def self.included(base)
      base.class_eval do
        helper_method :purity_params
        helper_method :current_purities
      end
    end

    def purity_params
      params
        .permit(:purity, purity: [])
        .tap do |p|
          p[:purity] = p[:purity].split(',') if p[:purity].is_a? String

          Array.wrap(p[:purity])
               .select { |purity| UserSetting::PURITY_STRING_KEYS.include?(purity) }
               .presence
        end
    end

    # Current viewable purities
    # Signed in users may override this via query string.
    def current_purities
      (user_signed_in? && purity_params[:purity]) || current_settings.purities
    end
  end

  module DebugMethods
    def self.included(base)
      base.class_eval do
        before_action :authorize_rack_mini_profiler_request
      end
    end

    def authorize_rack_mini_profiler_request
      if user_signed_in? && current_user.developer?
        Rack::MiniProfiler.authorize_request
      end
    end
  end

  module UserOnlineMethods
    def self.included(base)
      base.class_eval do
        before_action :track_online_user
        helper_method :users_online
      end
    end

    def users_online
      @users_online ||= ::UsersOnlineService.new
    end

    # Track signed in and visible users
    def track_online_user
      if user_signed_in? && !current_settings.invisible?
        users_online.track_user(current_user)
      end
    end
  end

  module CountryMethods
    def self.included(base)
      base.class_eval do
        before_action :update_user_country
      end
    end

    def update_user_country
      if user_signed_in? && current_profile.needs_country_code?
        country_code = request.location.try(:country_code)
        current_profile.update(country_code: country_code) if country_code.present?
      end
    end
  end

  include PurityMethods
  include DebugMethods
  include UserOnlineMethods
  include CountryMethods
end
