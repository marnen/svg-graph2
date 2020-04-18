source "https://rubygems.org"

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  gem 'guard-rspec'
  gem 'guard' # necessary only for guard-minitest
  gem 'guard-minitest'
end

group :test do
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'rspec'
  gem 'test-unit'
  gem 'simplecov', '< 0.18', require: false # CodeClimate doesn't support 0.18
end
