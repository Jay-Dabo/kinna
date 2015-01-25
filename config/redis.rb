redis_url = ENV['REDIS_URL'] || 'redis://127.0.0.1:6379'
REDIS_CONNECTION = Redis.new(url: redis_url)
