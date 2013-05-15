source 'http://ruby.taobao.org'
#source 'http://rubygems.org/'

gem 'rails', '3.2.12'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# gem 'sqlite3'
gem 'mysql2'

# REST api
gem 'grape', '~> 0.4.1'

# http client
gem 'httparty', '~> 0.11.0'

# json
gem 'multi_json', '~> 1.7.2'

# authentication
gem 'devise', '~> 2.2.3'
# admin dashboard
gem 'rails_admin'

gem 'simple_form'

gem 'exception_notification'

# Monitoring
gem 'newrelic_rpm'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'bootstrap-sass', '~> 2.3.1.0'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby
  gem 'execjs'

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'dalli'

group :development do
  gem 'pry-rails'
  gem "pry-nav"

  gem "better_errors"
  gem "binding_of_caller"

  gem 'guard-livereload'
end

group :test, :development do
  gem "rspec-rails", "~> 2.0"
end

group :test do 
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'guard-rspec'
  gem 'rb-fsevent', '~> 0.9'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
