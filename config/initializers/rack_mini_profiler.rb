Rack::MiniProfiler.config.storage_options = { host: '127.0.0.1', port: 6379 }
Rack::MiniProfiler.config.storage = Rack::MiniProfiler::RedisStore
Rack::MiniProfiler.config.skip_paths = ['/admin']

Rack::MiniProfiler.config.skip_schema_queries = true
Rack::MiniProfiler.config.start_hidden = true
