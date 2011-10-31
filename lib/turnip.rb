require "gherkin"
require "gherkin/formatter/tag_count_formatter"

require "turnip/version"
require "turnip/dsl"

module Turnip
  autoload :Loader, 'turnip/loader'
  autoload :Builder, 'turnip/builder'
  autoload :StepDefinition, 'turnip/step_definition'
  autoload :Placeholder, 'turnip/placeholder'

  class << self
    attr_accessor :type

    def run(content)
      Turnip::Builder.build(content).features.each do |feature|
        describe feature.name, feature.metadata_hash do
          feature.backgrounds.each do |background|
            before do
              background.steps.each do |step|
                Turnip::StepDefinition.execute(self, step)
              end
            end
          end
          feature.scenarios.each do |scenario|
            it scenario.name, scenario.metadata_hash do
              scenario.steps.each do |step|
                Turnip::StepDefinition.execute(self, step)
              end
            end
          end
        end
      end
    end
  end
end

Turnip.type = :turnip

RSpec::Core::Configuration.send(:include, Turnip::Loader)

RSpec.configure do |config|
  config.pattern << ",**/*.feature"
end

self.extend Turnip::DSL
