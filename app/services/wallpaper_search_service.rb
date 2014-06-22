class WallpaperSearchService
  attr_reader :options

  def initialize(options)
    @options = options

    # Remove blank array values
    @options.each do |_,option|
      option.reject!(&:blank?) if option.is_a? Array
    end
  end

  def execute
    wallpapers = Wallpaper.search(
      query: build_query,
      facets: build_facets,
      order: build_sort,
      page: @options[:page],
      per_page: @options[:per_page] || Wallpaper.default_per_page
    )

    # Updates requested resolution of each wallpaper.
    if options[:width].present? && options[:height].present?
      screen_resolution = ScreenResolution.find_by_dimensions(options[:width], options[:height])
      wallpapers.each do |wallpaper|
        # check_inclusion is disabled because search results are trusted.
        wallpaper.resize_image_to(screen_resolution, check_inclusion: false)
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

  private

    def build_facets
      {
        :tag => {
          :limit => 20
        },
        :category => {
          :limit => 10
        },
        :'color.hex' => {
          :limit => 20
        }
      }
    end

    def build_query
      musts = []
      must_nots = []

      # Handle query string
      if @options[:q].present?
        musts << {
          :query_string => {
            :query => @options[:q],
            :default_operator => 'AND',
            :lenient => true
          }
        }
      end

      # Handle tags
      if @options[:tags].present?
        @options[:tags].each do |tag|
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
      if @options[:exclude_tags].present?
        @options[:exclude_tags].each do |tag|
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
      if @options[:categories].present?
        @options[:categories].each do |category|
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
      if @options[:exclude_categories].present?
        @options[:exclude_categories].each do |category|
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

      # Handle purity
      musts << {
        :constant_score => {
          :filter => {
            :terms => {
              :purity => @options[:purity]
            }
          }
        }
      }

      # Handle width and height
      if @options[:resolution_exactness] == 'at_least'
        [:width, :height].each do |a|
          if @options[a].present?
            musts << {
              :range => {
                a => {
                  :gte => @options[a],
                  :boost => 2.0
                }
              }
            }
          end
        end
      else
        [:width, :height].each do |a|
          if @options[a].present?
            musts << {
              :constant_score => {
                :filter => {
                  :term => {
                    a => @options[a]
                  }
                }
              }
            }
          end
        end
      end

      # Handle colors
      if @options[:colors].present?
        @options[:colors].each do |color|
          musts << {
            :constant_score => {
              :filter => {
                :term => {
                  :'color.hex' => color
                }
              }
            }
          }
        end
      end

      # Handle user
      if @options[:user].present?
        musts << {
          :constant_score => {
            :filter => {
              :term => {
                :user => @options[:user]
              }
            }
          }
        }
      end

      # Handle aspect ratios
      if @options[:aspect_ratios].present?
        musts << {
          :constant_score => {
            :filter => {
              :terms => {
                :aspect_ratio => Array.wrap(@options[:aspect_ratios]).map { |aspect_ratio| aspect_ratio.tr('_', '.').to_f }
              }
            }
          }
        }
      end

      # Handle ordering
      case @options[:order]
      when 'random'
        musts << {
          :function_score => {
            :functions => [
              {
                :random_score => {
                  :seed => @options[:random_seed] || Time.now.to_i
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

      {
        :bool => {
          :must => musts,
          :must_not => must_nots
        }
      }
    end

    def build_sort
      sorts = {}

      # Handle ordering
      case @options[:order]
      when 'random'
      when 'popular'
        sorts['_score'] = 'desc'
      else
        # Sort using created_at by default
        sorts['created_at'] = 'desc'
      end

      sorts
    end
end