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
  autoload :ScenarioRunner, 'turnip/scenario_runner'
  autoload :RunnerDSL, 'turnip/runner_dsl'
  autoload :ScenarioContext, 'turnip/scenario_context'

  class << self
    attr_accessor :type

    def run(feature_file)
      Turnip::Builder.build(feature_file).features.each do |feature|
        feature.metadata_hash[:file_path] = feature_file.file_name
        describe feature.name, feature.metadata_hash do
          feature.scenarios.each do |scenario|
            it scenario.name, scenario.metadata_hash do
              Turnip::ScenarioRunner.new(self).load(Turnip::ScenarioContext.new(feature, scenario)).run
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
