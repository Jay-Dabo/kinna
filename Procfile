web: bundle exec unicorn -p $PORT -c .config/unicorn.rb
queue: env TERM_CHILD=1 QUEUE=* bundle exec rake resque:work
#mailcatcher: env mailcatcher -f --http-ip 0.0.0.0
