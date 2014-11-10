require 'resque'
require File.dirname(__FILE__)+'/redis'

worker_processes 4
timeout 15
preload_app true

before_fork do |server, worker|
  # Disconnect since the database connection will not carry over
  if defined? ActiveRecord::Base
    ActiveRecord::Base.connection.disconnect!
    Rails.logger.info "Disconnected from db"
  end

  if defined?(Resque)
    Resque.redis.quit
    Rails.logger.info('Disconnected from Redis')
  end
end

after_fork do |server, worker|
  # Start up the database connection again in the worker
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
    Rails.logger.info "Connecting to db"
  end

  if defined?(Resque)
    Resque.redis = REDIS_CONNECTION
    Rails.logger.info('Connected to Redis')
  end
end
