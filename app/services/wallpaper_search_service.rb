class WallpaperSearchService
  def initialize(options)
    @options = options
  end

  def execute
    payload = build_payload

    Wallpaper.search nil,
      query: payload[:query],
      facets: build_facets,
      order: payload[:sort],
      page: @options[:page],
      per_page: @options[:per_page] || Wallpaper.default_per_page
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
        :tags => {
          :terms => {
            :field => 'tags',
            :size => 20
          }
        },
        :categories => {
          :terms => {
            :field => 'categories',
            :size => 10
          }
        },
        :colors => {
          :terms => {
            :field => 'colors.hex',
            :size => 20
          }
        }
      }
    end

    def build_payload
      payload = {
        :query => {
          :bool => {
            :must => [],
            :must_not => []
          }
        },
        :sort => []
      }

      payload[:query][:bool][:must] << {
        :term => {
          :'approved' => true
        }
      }

      # Handle query string
      if @options[:q].present?
        payload[:query][:bool][:must] << {
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
          payload[:query][:bool][:must] << {
            :constant_score => {
              :filter => {
                :term => {
                  :'tags' => tag
                }
              }
            }
          }
        end
      end

      # Handle tag exclusions
      if @options[:exclude_tags].present?
        @options[:exclude_tags].each do |tag|
          payload[:query][:bool][:must_not] << {
            :constant_score => {
              :filter => {
                :term => {
                  :'tags' => tag
                }
              }
            }
          }
        end
      end

      # Handle categories
      if @options[:categories].present?
        @options[:categories].each do |category|
          payload[:query][:bool][:must] << {
            :constant_score => {
              :filter => {
                :term => {
                  :'categories' => category
                }
              }
            }
          }
        end
      end

      # Handle categories exclusions
      if @options[:exclude_categories].present?
        @options[:exclude_categories].each do |category|
          payload[:query][:bool][:must_not] << {
            :constant_score => {
              :filter => {
                :term => {
                  :'categories' => category
                }
              }
            }
          }
        end
      end

      # Handle purity
      payload[:query][:bool][:must] << {
        :constant_score => {
          :filter => {
            :terms => {
              :'purity' => @options[:purity]
            }
          }
        }
      }

      # Handle width and height
      if @options[:resolution_exactness] == 'at_least'
        [:width, :height].each do |a|
          if @options[a].present?
            payload[:query][:bool][:must] << {
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
            payload[:query][:bool][:must] << {
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
          payload[:query][:bool][:must] << {
            :constant_score => {
              :filter => {
                :term => {
                  :'colors.hex' => color
                }
              }
            }
          }

          payload[:sort] << {
            :'colors.percentage' => {
              :order => 'desc',
              :nested_filter => {
                :term => {
                  :'colors.hex' => color
                }
              }
            }
          }
        end
      end

      # Handle user
      if @options[:user].present?
        payload[:query][:bool][:must] << {
          :constant_score => {
            :filter => {
              :term => {
                :'user' => @options[:user]
              }
            }
          }
        }
      end

      # Handle aspect ratios
      if @options[:aspect_ratios].present?
        payload[:query][:bool][:must] << {
          :constant_score => {
            :filter => {
              :terms => {
                :'aspect_ratio' => Array.wrap(@options[:aspect_ratios]).map { |aspect_ratio| aspect_ratio.tr('_', '.').to_f }
              }
            }
          }
        }
      end

      case @options[:order]
      when 'random'
        payload[:query][:bool][:must] << {
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
        payload[:sort] << '_score'
      when 'popular'
        payload[:query][:bool][:must] << {
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
        payload[:sort] << '_score'
      else
        payload[:sort] << {
          :'approved_at' => 'desc'
        }
      end

      payload
    end
end