require "gherkin"
require "gherkin/formatter/tag_count_formatter"

require "turnip/version"
require "turnip/dsl"

require 'rspec'

module Turnip
  class Pending < StandardError; end
  class Ambiguous < StandardError; end

  autoload :Config, 'turnip/config'
  autoload :Loader, 'turnip/loader'
  autoload :Builder, 'turnip/builder'
  autoload :StepDefinition, 'turnip/step_definition'
  autoload :Placeholder, 'turnip/placeholder'
  autoload :Table, 'turnip/table'
  autoload :StepLoader, 'turnip/step_loader'
  autoload :StepModule, 'turnip/step_module'

  module Execute
    def step(description, extra_arg=nil)
      matches = methods.map do |method|
        next unless method.to_s.start_with?("step:")
        send(method.to_s).match(description)
      end.compact
      raise Turnip::Pending, description if matches.length == 0
      raise Turnip::Ambiguous, description if matches.length > 1
      send("execute: #{matches.first.expression}", *(matches.first.params + [extra_arg].compact))
    end
  end

  module Define
    def step(expression, &block)
      step = Turnip::StepDefinition.new(expression, &block)
      send(:define_method, "step: #{expression}") { step }
      send(:define_method, "execute: #{expression}", &block)
    end
  end

  # The global step module
  module Steps
    extend Define
    include Execute

    def step(description, extra_arg=nil)
      begin
        super
      rescue Turnip::Pending
        pending("No such step: '#{description}'")
      end
    end
  end

  class << self
    attr_accessor :type

    def run(feature_file)
      Turnip::Builder.build(feature_file).features.each do |feature|
        describe feature.name, feature.metadata_hash do
          before do
            feature.backgrounds.map(&:steps).flatten.each do |step|
              step(step.description, step.extra_arg)
            end
          end
          feature.scenarios.each do |scenario|
            describe scenario.name, scenario.metadata_hash do
              it scenario.steps.map(&:description).join(' -> ') do
                scenario.steps.each do |step|
                  step(step.description, step.extra_arg)
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

self.extend Turnip::DSL
