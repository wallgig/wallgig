module WallpaperSearchParams
  extend ActiveSupport::Concern

  included do
    helper_method :search_options
  end

  def search_params(load_session = true)
    params.permit(:q, :page, :per_page, :width, :height, :order, :user, :resolution_exactness, purity: [], exclude_categories: [], categories: [], tags: [], exclude_tags: [], colors: [])
  end

  def search_options
    @search_options ||= begin
      search_options = search_params

      # Default options
      search_options[:order]  ||= 'latest'

      # Ensure array
      search_options[:tags]               ||= []
      search_options[:exclude_tags]       ||= []
      search_options[:categories]         ||= []
      search_options[:exclude_categories] ||= []
      search_options[:colors]             ||= []

      # TODO move to UserSetting model
      search_options[:purity] ||= current_purities
      search_options[:purity] = search_options[:purity].select { |p| ['sfw', 'sketchy', 'nsfw'].include?(p) }

      search_options[:per_page] = UserSetting.per_page.find_value(search_options[:per_page])
      search_options[:per_page] ||= current_settings.per_page

      # TODO move to UserSetting model
      search_options[:resolution_exactness] = nil unless ['exactly', 'at_least'].include?(search_options[:resolution_exactness])
      search_options[:resolution_exactness] ||= 'at_least'

      search_options[:user] = @user.username if @user.present?

      # Handle random
      if search_options[:order] == 'random'
        search_options[:random_seed] = session[:random_seed]
        search_options[:random_seed] = nil if search_options[:page].to_i <= 1
        search_options[:random_seed] ||= Time.now.to_i
        session[:random_seed] = search_options[:random_seed]
      end

      # Reset page
      search_options[:page] = nil

      search_options
    end
  end
end
