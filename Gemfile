source 'https://rubygems.org'

ruby '2.1.5'
gem 'rails', '4.2.0'
gem 'pg'
gem 'mini_magick'

group :test, :development do
  # Use rspec for testing
  gem 'rspec-rails', '~> 3.1'
  gem "factory_girl_rails", "~> 4.0"
  gem 'database_cleaner'
end

group :test do
  gem 'webmock'
  gem 'shoulda'
end

gem 'nokogiri'

gem 'marc'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

gem 'httparty'

gem 'rack-cors', :require => 'rack/cors'

gem 'will_paginate', '~> 3.0.5'
gem 'responders', '~> 2.0'

gem 'apipie-rails' # For documentation

group :development do
  gem 'capistrano',  '~> 3.4.0'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano-passenger'
  gem 'capistrano-bundler', '~> 1.1.2'
  gem 'capistrano-rvm'
end

gem 'unicode', '~> 0.4.4.2'

gem 'rsolr'
