require "gherkin"
require "gherkin/formatter/tag_count_formatter"

require "turnip/version"
require "turnip/dsl"

require 'rspec'

module Turnip
  class Pending < StandardError; end

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

  module Step
    def self.define(object, text, &block)
      step = Turnip::StepDefinition.new(text, &block)
      object.send(:define_method, "step: #{step.expression}") { step }
      object.send(:define_method, "execute: #{step.expression}", &block)
    end

    def self.execute(object, text)
      match = find_step(object, text)
      if match
        object.send("execute: #{match.expression}", *match.params)
      else
        raise Turnip::Pending, text
      end
    end

    def self.find_step(object, text)
      object.methods.each do |method|
        method = method.to_s
        next unless method.start_with?("step:")
        match = object.send(method).match(text)
        return match if match
      end
      nil
    end
  end

  module StepDSL
    def step(text, &block)
      Step.define(self, text, &block)
    end
  end

  # The global step module
  module Steps
    extend StepDSL
  end

  class << self
    attr_accessor :type

    def run(feature_file)
      Turnip::Builder.build(feature_file).features.each do |feature|
        describe feature.name, feature.metadata_hash do
          feature.scenarios.each do |scenario|
            it scenario.name, scenario.metadata_hash do
              scenario.steps.each do |step|
                begin
                  turnip_step(step.description)
                rescue Turnip::Pending
                  pending("No such step: '#{step.description}'")
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
  config.include Turnip::Steps
  config.pattern << ",**/*.feature"
end

class Object
  def turnip_step(text)
    Turnip::Step.execute(self, text)
  end
end

self.extend Turnip::DSL
