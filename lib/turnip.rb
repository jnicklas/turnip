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
  autoload :RunnerDSL, 'turnip/runner_dsl'
  autoload :ScenarioContext, 'turnip/scenario_context'

  module Step
    def self.define(object, expression, &block)
      step = Turnip::StepDefinition.new(expression, &block)
      object.send(:define_method, "step: #{step.expression}") { step }
      object.send(:define_method, "execute: #{step.expression}", &block)
    end

    def self.execute(object, description)
      match = find_step(object, description)
      object.send("execute: #{match.expression}", *match.params)
    end

    def self.find_step(object, description)
      matches = object.methods.inject([]) do |agg, method|
        method = method.to_s
        if method.start_with?("step:")
          agg << object.send(method).match(description)
        end
        agg
      end.compact
      raise Pending, description if matches.length == 0
      raise Ambiguous, description if matches.length > 1
      matches.first
    end
  end

  module StepDSL
    def step(expression, &block)
      Step.define(self, expression, &block)
    end
  end

  # The global step module
  module Steps
    extend StepDSL

    def step(description)
      turnip_step(description)
    end
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
  def turnip_step(description)
    Turnip::Step.execute(self, description)
  end
end

self.extend Turnip::DSL
