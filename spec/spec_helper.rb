RSpec.configure do |config|
  config.before(:each, :turnip => true) do
    require File.expand_path('../examples/steps', File.dirname(__FILE__))
  end
end
