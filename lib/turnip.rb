require "gherkin"
require "gherkin/formatter/tag_count_formatter"

require "turnip/version"
require "turnip/dsl"

require 'rspec'

module Turnip
  autoload :Config, 'turnip/config'
  autoload :FeatureFile, 'turnip/feature_file'
  autoload :Loader, 'turnip/loader'
  autoload :Builder, 'turnip/builder'
  autoload :StepDefinition, 'turnip/step_definition'
  autoload :Placeholder, 'turnip/placeholder'
  autoload :Table, 'turnip/table'
  autoload :StepLoader, 'turnip/step_loader'
  autoload :StepModule, 'turnip/step_module'
  autoload :ScenarioContext, 'turnip/scenario_context'

  class << self
    attr_accessor :type

    def run(feature_file)
      Turnip::Builder.build(feature_file).features.each do |feature|
        describe feature.name, feature.metadata_hash do

          feature_tags = feature.active_tags.uniq

          feature.backgrounds.each do |background|
            before do
              background.steps.each do |step|
                Turnip::StepDefinition.execute(self, Turnip::StepModule.all_steps_for(*feature_tags), step)
              end
            end
          end
          feature.scenarios.each do |scenario|
            context scenario.metadata_hash do

              scenario_tags = (feature_tags + scenario.active_tags).uniq
              Turnip::StepModule.modules_for(*scenario_tags).each { |mod| include mod }

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
