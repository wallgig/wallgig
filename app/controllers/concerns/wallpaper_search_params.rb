module WallpaperSearchParams
  extend ActiveSupport::Concern

  included do
    helper_method :search_options
  end

  def search_params(load_session = true)
    params.permit(:q, :page, :width, :height, :order, :user, :resolution_exactness, purity: [], exclude_categories: [], categories: [], tags: [], exclude_tags: [], colors: []).tap do |p|
      p.reverse_merge! session[:search_params] if load_session && p.blank? && session[:search_params].present?

      # default values
      p[:order]  ||= 'latest'
      p[:purity] ||= current_purities
    end
  end

  def search_options
    @search_options ||= begin
      search_options = search_params

      search_options[:per_page] = current_settings.per_page

      if search_options[:order] == 'random'
        search_options[:random_seed] = session[:random_seed]
        search_options[:random_seed] = nil if search_options[:page].to_i <= 1
        search_options[:random_seed] ||= Time.now.to_i
        session[:random_seed] = search_options[:random_seed]
      end

      search_options[:user] = @user.username if @user.present?

      search_options
    end
  end
end
