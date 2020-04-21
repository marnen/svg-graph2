source "https://rubygems.org"

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  gem 'guard-rspec', require: false
end

group :test do
  gem 'capybara'
  gem 'faker'
  gem 'rspec'
  gem 'rspec-its'  # TODO: consider removing its and writing better descriptions instead.
  gem 'simplecov', '< 0.18', require: false # CodeClimate doesn't support 0.18
end
