require "pry"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end

Dir.glob(File.expand_path("../examples/**/*steps.rb", File.dirname(__FILE__))) { |f| require f }
