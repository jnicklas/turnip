require 'capybara/rspec'

RSpec.configure do |config|
  config.before do
    current_example = RSpec.current_example

    if self.class.include?(Capybara::DSL) and current_example.metadata[:turnip]
      Capybara.current_driver = Capybara.javascript_driver if current_example.metadata.has_key?(:javascript)
      current_example.metadata.each do |tag, value|
        has_driver = Capybara::VERSION >= '3.33.0' ? !Capybara.drivers[tag].nil? : Capybara.drivers.has_key?(tag)
        if has_driver
          Capybara.current_driver = tag
        end
      end
    end
  end
end
