if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

require 'capybara'
require 'faker'
require 'rspec/its'
