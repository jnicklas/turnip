require "gherkin"
require "gherkin/formatter/tag_count_formatter"

require "turnip/version"
require "turnip/dsl"

module Turnip
  autoload :Config, 'turnip/config'
  autoload :Loader, 'turnip/loader'
  autoload :Builder, 'turnip/builder'
  autoload :StepDefinition, 'turnip/step_definition'
  autoload :Placeholder, 'turnip/placeholder'
  autoload :Table, 'turnip/table'
  autoload :StepModule, 'turnip/step_module'

  class << self
    attr_accessor :type

    def run(content)
      Turnip::Builder.build(content).features.each do |feature|
        describe feature.name, feature.metadata_hash do

          feature_tags = Turnip::StepModule.active_tags(feature.metadata_hash.keys)
          include *Turnip::StepModule.modules_for(*feature_tags)

          feature.backgrounds.each do |background|
            before do
              background.steps.each do |step|
                Turnip::StepDefinition.execute(self, Turnip::StepModule.all_steps_for(*feature_tags), step)
              end
            end
          end
          feature.scenarios.each do |scenario|
            context scenario.metadata_hash do

              scenario_tags = Turnip::StepModule.active_tags(scenario.metadata_hash.keys + feature.metadata_hash.keys)
              include *Turnip::StepModule.modules_for(*scenario_tags)

              it scenario.name do
                scenario.steps.each do |step|
                  Turnip::StepDefinition.execute(self, Turnip::StepModule.all_steps_for(*scenario_tags), step)
                end
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
