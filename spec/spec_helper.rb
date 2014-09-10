require "pry"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.before(raise_error_for_unimplemented_steps: true) do
    config.stub(:raise_error_for_unimplemented_steps) { true }
  end
end

Dir.glob(File.expand_path("../examples/**/*steps.rb", File.dirname(__FILE__))) { |f| require f }
