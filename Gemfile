source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.7'
# Use postgresql as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'bootstrap-sass', '~> 3'
gem 'resque', '~> 1.25'
gem 'devise', '~> 3.4'

gem 'simple_form', git: 'https://github.com/plataformatec/simple_form.git'
gem 'protected_attributes', '~> 1.0.5'

gem 'foreman'
gem 'cancancan', '~> 1.9'
gem 'state_machine', '~> 1.2'
gem 'draper', '~> 1.3'
gem 'haml', '~> 4.0'
gem 'angularjs-rails'
gem 'active_model_serializers'
gem 'gon'
gem 'angular-ui-bootstrap-rails'
gem 'country_select'
gem 'kaminari', '~> 0.16'
gem 'bootstrap-kaminari-views'
gem 'paperclip', '~> 4.2'

group :test, :development do
  gem 'factory_girl_rails'
  gem 'i18n-tasks'                    # $ i18n-tasks missing; a great way to find missing translations
  gem 'byebug'                        # 'debugger' replacement
  gem 'rubocop', require: false
end
group :test do
  gem 'minitest'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'capybara-webkit'
  gem 'resque_unit'
  gem 'simplecov'
end
