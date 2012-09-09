require 'capybara/rspec'

RSpec.configure do |config|
  config.before do
    if self.class.include?(Capybara::DSL) and example.metadata[:turnip]
      Capybara.current_driver = Capybara.javascript_driver if example.metadata.has_key?(:javascript)
      example.metadata.each do |tag, value|
        if Capybara.drivers.has_key?(tag)
          Capybara.current_driver = tag
        end
      end
    end
  end
end
