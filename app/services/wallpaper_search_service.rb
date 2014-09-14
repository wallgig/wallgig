class WallpaperSearchService
  # TODO optimize values
  COLOR_FILTER_H_RANGE = 20 # 10
  COLOR_FILTER_S_RANGE = 10 # 5
  COLOR_FILTER_V_RANGE = 10 # 5

  attr_reader :options

  def initialize(options)
    @options = options

    # Remove blank array values
    @options.each do |_,option|
      option.reject!(&:blank?) if option.is_a? Array
    end
  end

  def resolution_exactness_is_at_least?
    options[:resolution_exactness].to_s.downcase == 'at_least'
  end

  def execute
    wallpapers = build_query.execute

    # Updates requested resolution of each wallpaper.
    if !resolution_exactness_is_at_least? && options[:width].present? && options[:height].present?
      screen_resolution = ScreenResolution.find_by_dimensions(options[:width], options[:height])
      unless screen_resolution.nil?
        wallpapers.each do |wallpaper|
          # check_inclusion is disabled because search results are trusted.
          wallpaper.resize_image_to(screen_resolution, check_inclusion: false)
        end
      end
    end

    wallpapers
  rescue Elasticsearch::Transport::Transport::Errors::BadRequest => e
    # Reraise error unless in production
    raise e unless Rails.env.production?

    # Log error if something went wrong
    Rails.logger.error e.message
    e.backtrace.each { |line| Rails.logger.error line }

    Wallpaper.none
  end

  def color_option
    @color_option ||= begin
      return if options[:color].blank?

      color = Color::RGB.from_html(options[:color])
      r, g, b = color.r, color.g, color.b
      max_rgb = [r, g, b].max
      min_rgb = [r, g, b].min
      delta = max_rgb - min_rgb
      v = max_rgb * 100

      if max_rgb == 0.0
        s = 0.0
      else
        s = delta / max_rgb * 100
      end

      if s == 0.0
        h = 0.0
      else
        if r == max_rgb
          h = (g - b) / delta
        elsif g == max_rgb
          h = 2 + (b - r) / delta
        elsif b == max_rgb
          h = 4 + (r - g) / delta
        end

        h *= 60.0
        h += 360.0 if h < 0
      end

      {
        h: h,
        s: s,
        v: v
      }
    end
  end

  private
  def build_query
    query = Wallpaper.lookup('*',
      query: build_query_option,
      where: build_where_option,
      facets: build_facets_option,
      order: build_order_option,
      page: options[:page],
      per_page: options[:per_page] || Wallpaper.default_per_page,
      execute: false
    )

    # Advanced queries
    color_filter = build_color_filter
    if color_filter.present?
      query.body[:filter][:and] ||= []
      query.body[:filter][:and] << build_color_filter
    end

    query
  end

  def build_query_option
    musts = []
    must_nots = []

    # Handle query string
    if options[:q].present?
      musts << {
        :query_string => {
          :query => options[:q],
          :default_operator => 'AND',
          :lenient => true
        }
      }
    end

    # Handle tags
    if options[:tags].present?
      options[:tags].each do |tag|
        musts << {
          :constant_score => {
            :filter => {
              :term => {
                :tag => tag
              }
            }
          }
        }
      end
    end

    # Handle tag exclusions
    if options[:exclude_tags].present?
      options[:exclude_tags].each do |tag|
        must_nots << {
          :constant_score => {
            :filter => {
              :term => {
                :tag => tag
              }
            }
          }
        }
      end
    end

    # Handle categories
    if options[:categories].present?
      options[:categories].each do |category|
        musts << {
          :constant_score => {
            :filter => {
              :term => {
                :category => category
              }
            }
          }
        }
      end
    end

    # Handle categories exclusions
    if options[:exclude_categories].present?
      options[:exclude_categories].each do |category|
        must_nots << {
          :constant_score => {
            :filter => {
              :term => {
                :category => category
              }
            }
          }
        }
      end
    end

    # Handle width and height
    if resolution_exactness_is_at_least?
      [:width, :height].each do |a|
        if options[a].present?
          musts << {
            :range => {
              a => {
                :gte => options[a],
                :boost => 2.0
              }
            }
          }
        end
      end
    else
      [:width, :height].each do |a|
        if options[a].present?
          musts << {
            :constant_score => {
              :filter => {
                :term => {
                  a => options[a]
                }
              }
            }
          }
        end
      end
    end

    # Handle aspect ratios
    if options[:aspect_ratios].present?
      musts << {
        :constant_score => {
          :filter => {
            :terms => {
              :aspect_ratio => Array.wrap(options[:aspect_ratios]).map { |aspect_ratio| aspect_ratio.tr('_', '.').to_f }
            }
          }
        }
      }
    end

    # Handle ordering
    case options[:order]
    when 'random'
      musts << {
        :function_score => {
          :functions => [
            {
              :random_score => {
                :seed => options[:random_seed] || Time.now.to_i
              }
            }
          ]
        }
      }
    when 'popular'
      musts << {
        :function_score => {
          :functions => [
            {
              :script_score => {
                :script => Wallpaper::POPULARITY_SCRIPT
              }
            }
          ]
        }
      }
    end

    if color_option.present?
      musts << {
        function_score: {
          boost_mode: :replace,
          query: {
            nested: {
              path: :color,
              query: {
                function_score: {
                  score_mode: :multiply,
                  functions: [
                    {
                      exp: {
                        h: {
                          origin: color_option[:h],
                          offset: 2,
                          scale: 4
                        }
                      }
                    },
                    {
                      exp: {
                        s: {
                          origin: color_option[:s],
                          offset: 4,
                          scale: 8
                        }
                      }
                    },
                    {
                      exp: {
                        v: {
                          origin: color_option[:v],
                          offset: 4,
                          scale: 8
                        }
                      }
                    },
                    {
                      linear: {
                        score: {
                          origin: 100,
                          offset: 5,
                          scale: 10
                        }
                      }
                    }
                  ]
                }
              }
            }
          }
        }
      }
    end

    if musts.empty? and must_nots.empty?
      { :match_all => {} }
    else
      {
        :bool => {
          :must => musts,
          :must_not => must_nots
        }
      }
    end
  end

  def build_color_filter
    return if color_option.blank?

    {
      nested: {
        path: :color,
        filter: {
          and: [
            {
              range: {
                h: {
                  gte: color_option[:h] - COLOR_FILTER_H_RANGE,
                  lte: color_option[:h] + COLOR_FILTER_H_RANGE
                }
              }
            },
            {
              range: {
                s: {
                  gte: color_option[:s] - COLOR_FILTER_S_RANGE,
                  lte: color_option[:s] + COLOR_FILTER_S_RANGE
                }
              }
            },
            {
              range: {
                v: {
                  gte: color_option[:v] - COLOR_FILTER_V_RANGE,
                  lte: color_option[:v] + COLOR_FILTER_V_RANGE
                }
              }
            }
          ]
        }
      }
    }
  end

  def build_where_option
    where = {}

    where[:purity] = options[:purity] if options[:purity].any?
    where[:user] = options[:user] if options[:user].present?

    where
  end

  def build_order_option
    order = {}

    # Handle ordering
    case options[:order]
      when 'random'
      when 'popular'
        order[:_score] = :desc
      else
        # Sort using created_at by default
        order[:created_at] = :desc
    end

    order
  end

  def build_facets_option
    facets = {}

    facets[:tag] = { limit: 20 }
    facets[:category] = { limit: 10 }

    facets
  end
end
