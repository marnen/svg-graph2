if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

require 'capybara'
require 'faker'
require 'rspec/its'

module FilenameFor
  def filename_for(example)
    example.full_description.downcase.gsub /\W/, '_'
  end
end

RSpec.configure do |config|
  config.include FilenameFor
end
