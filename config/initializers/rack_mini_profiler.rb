Rack::MiniProfiler.config.storage = Rack::MiniProfiler::RedisStore
Rack::MiniProfiler.config.skip_paths = ['/admin']

Rack::MiniProfiler.config.skip_schema_queries = true
Rack::MiniProfiler.config.start_hidden = true
