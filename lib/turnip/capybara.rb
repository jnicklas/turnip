require 'capybara/rspec'

RSpec.configure do |config|
  config.before do
    current_example = RSpec.current_example if RSpec.respond_to?(:current_example)
    current_example ||= example

    if self.class.include?(Capybara::DSL) and current_example.metadata[:turnip]
      Capybara.current_driver = Capybara.javascript_driver if current_example.metadata.has_key?(:javascript)
      current_example.metadata.each do |tag, value|
        if Capybara.drivers.has_key?(tag)
          Capybara.current_driver = tag
        end
      end
    end
  end
end
