require 'redmon/config'
require 'redmon/redis'
require 'redmon/app'

#
# Optional config overrides
#
Redmon.configure do |config|
  config.redis_url = ENV['REDIS_SERVER_URL'] || 'redis://127.0.0.1:6379'
  config.namespace = 'redmon'
end
