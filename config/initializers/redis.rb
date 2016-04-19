uri = URI.parse(ENV['REDIS_SERVER_URL'] || 'redis://127.0.0.1:6379')
Redis.current = Redis.new(host: uri.host, port: uri.port, password: uri.password)
