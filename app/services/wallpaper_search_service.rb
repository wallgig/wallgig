class WallpaperSearchService
  def initialize(options)
    @options = options
  end

  def execute
    Wallpaper.tire.search nil,
                          load: true,
                          payload: build_payload,
                          page: @options[:page],
                          per_page: (@options[:per_page] || Wallpaper.default_per_page)
  rescue Tire::Search::SearchRequestFailed => e
    Rails.logger.error e.message
    e.backtrace.each { |line| Rails.logger.error line }
    Wallpaper.none
  end

  private
    def build_payload
      payload = {
        :query => {
          :bool => {
            :must => [],
            :must_not => []
          }
        },
        :sort => [],
        :facets => {}
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
            :term => {
              :'tags' => {
                :value => tag
              }
            }
          }
        end
      end

      # Handle tag exclusions
      if @options[:exclude_tags].present?
        @options[:exclude_tags].each do |tag|
          payload[:query][:bool][:must_not] << {
            :term => {
              :'tags' => {
                :value => tag
              }
            }
          }
        end
      end

      # Handle purity
      payload[:query][:bool][:must] << {
        :terms => {
          :'purity' => @options[:purity] || ['sfw']
        }
      }

      # Handle width and height
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

      # Handle colors
      if @options[:colors].present?
        @options[:colors].each do |color|
          payload[:query][:bool][:must] << {
            :term => {
              :'colors.hex' => {
                :value => color
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
          :term => {
            :'user' => @options[:user]
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
          :'created_at' => 'desc'
        }
      end

      payload[:facets] = {
        :tags => {
          :terms => {
            :field => 'tags',
            :size => 20
          }
        },
        :colors => {
          :terms => {
            :field => 'colors.hex',
            :size => 20
          }
        }
      }

      payload
    end
end