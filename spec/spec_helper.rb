require 'rubygems'
require 'bundler/setup'
require 'webmock/rspec'
require 'task_helper'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
  config.order = 'random'

  config.before(:each) do
    WebMock.disable_net_connect!
    stub_request(:any, /mytaskhelper/).to_rack(FakeMTH)
  end
end
