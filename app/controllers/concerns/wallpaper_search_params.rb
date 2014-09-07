module WallpaperSearchParams
  extend ActiveSupport::Concern

  GLUE = ','
  ARRAY_PARAMS = %i(categories exclude_categories tags exclude_tags colors aspect_ratios)

  included do
    helper_method :search_options
    helper_method :compact_search_options
  end

  def search_params(load_session = true)
    permitted_scalars = %i(q page per_page width height order user resolution_exactness) + ARRAY_PARAMS

    permitted_arrays = {}
    ARRAY_PARAMS.each do |key|
      permitted_arrays[key] = []
    end

    params.permit(permitted_scalars, *permitted_arrays)
  end

  def search_options
    @search_options ||= begin
      search_options = search_params

      # Ensure array
      ARRAY_PARAMS.each do |key|
        if search_options[key].is_a? String
          search_options[key] = search_options[key].split(GLUE)
        else
          search_options[key] ||= []
        end
      end

      # Validate order
      search_options[:order] = nil unless ['latest', 'popular', 'random'].include?(search_options[:order])
      search_options[:order] ||= 'latest'

      # Set purity
      search_options[:purity] = current_purities

      # Validate per page
      search_options[:per_page] = UserSetting.per_page.find_value(search_options[:per_page]) if search_options[:per_page].present?
      search_options[:per_page] ||= current_settings.per_page

      # Validate resolution exactness
      search_options[:resolution_exactness] = UserSetting.resolution_exactness.find_value(search_options[:resolution_exactness]) if search_options[:resolution_exactness].present?
      search_options[:resolution_exactness] ||= current_settings.resolution_exactness

      # Validate aspect ratios
      if search_options[:aspect_ratios].present?
        search_options[:aspect_ratios] = Array.wrap(search_options[:aspect_ratios]).select { |aspect_ratio| UserSetting.aspect_ratios.find_value(aspect_ratio).present? }.presence
      end
      search_options[:aspect_ratios] ||= current_settings.aspect_ratios.to_a

      # Set user if we're looking at a user page
      search_options[:user] = @user.username if @user.present?

      # Handle random seed
      if search_options[:order] == 'random'
        search_options[:random_seed] = session[:random_seed]
        search_options[:random_seed] = nil if search_options[:page].to_i <= 1
        search_options[:random_seed] ||= Time.now.to_i
        session[:random_seed] = search_options[:random_seed]
      end

      search_options
    end
  end

  def compact_search_options
    compact_search_options = search_options.reject { |k, v| v.blank? }

    compact_search_options.each do |k, v|
      compact_search_options[k] = v.join(GLUE) if v.is_a? Array
    end
  end
end
