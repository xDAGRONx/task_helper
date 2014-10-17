require 'rubygems'
require 'bundler/setup'
require 'mth'

RSpec.configure do |config|
  config.mock_with :rspec
  config.order = 'random'
end
