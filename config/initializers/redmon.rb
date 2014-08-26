require 'redmon/config'
require 'redmon/redis'
require 'redmon/app'

#
# Optional config overrides
#
Redmon.configure do |config|
  config.redis_url = 'redis://127.0.0.1:6379'
  config.namespace = 'redmon'
end
