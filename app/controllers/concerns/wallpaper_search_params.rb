module WallpaperSearchParams
  extend ActiveSupport::Concern

  included do
    helper_method :search_options
  end

  def search_params(load_session = true)
    params.permit(
      :q,:page, :per_page, :width, :height, :order, :user, :resolution_exactness,
      purity: [],
      categories: [],
      exclude_categories: [],
      tags: [],
      exclude_tags: [],
      colors: [],
      aspect_ratios: []
    )
  end

  def search_options
    @search_options ||= begin
      search_options = search_params

      # Default options
      search_options[:order]  ||= 'latest'

      # Ensure array
      %i(categories exclude_categories tags exclude_tags colors).each do |key|
        search_options[key] ||= []
      end

      # TODO move to UserSetting model
      search_options[:purity] ||= current_purities
      search_options[:purity] = search_options[:purity].select { |p| ['sfw', 'sketchy', 'nsfw'].include?(p) }

      search_options[:per_page] = UserSetting.per_page.find_value(search_options[:per_page])
      search_options[:per_page] ||= current_settings.per_page

      # TODO move to UserSetting model
      search_options[:resolution_exactness] = nil unless ['exactly', 'at_least'].include?(search_options[:resolution_exactness])
      search_options[:resolution_exactness] ||= 'at_least'

      # Validate aspect ratios
      if search_options[:aspect_ratios].nil?
        search_options[:aspect_ratios] = current_settings.aspect_ratios.to_a
      else
        search_options[:aspect_ratios].select! { |aspect_ratio| UserSetting.aspect_ratios.find_value(aspect_ratio).present? }
      end

      search_options[:user] = @user.username if @user.present?

      # Handle random
      if search_options[:order] == 'random'
        search_options[:random_seed] = session[:random_seed]
        search_options[:random_seed] = nil if search_options[:page].to_i <= 1
        search_options[:random_seed] ||= Time.now.to_i
        session[:random_seed] = search_options[:random_seed]
      end

      search_options
    end
  end
end
