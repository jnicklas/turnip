module IntegrationHelpers
  def command
    example.metadata[:example_group][:description_args].first
  end

  def run_command
    %x(#{command})
  end

  def result
    @result ||= run_command
  end
end

RSpec.configure do |config|
  config.include IntegrationHelpers, :type => :integration
  config.before(:each, :turnip => true) do
    require File.expand_path('../examples/steps', File.dirname(__FILE__))
  end
end
