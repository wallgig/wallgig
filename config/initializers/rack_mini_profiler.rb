uri = URI.parse(ENV['REDIS_SERVER_URL'] || 'redis://127.0.0.1:6379')
Rack::MiniProfiler.config.storage_options = { :host => uri.host, :port => uri.port, :password => uri.password }
Rack::MiniProfiler.config.storage = Rack::MiniProfiler::RedisStore
Rack::MiniProfiler.config.skip_paths = ['/admin']

Rack::MiniProfiler.config.skip_schema_queries = true
Rack::MiniProfiler.config.start_hidden = true
