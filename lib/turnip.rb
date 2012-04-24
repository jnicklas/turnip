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

  class << self
    attr_accessor :step_dirs
  end

  module Execute
    def step(description, extra_arg=nil)
      matches = methods.map do |method|
        next unless method.to_s.start_with?("match: ")
        send(method.to_s, description)
      end.compact
      raise Turnip::Pending, description if matches.length == 0
      raise Turnip::Ambiguous, description if matches.length > 1
      send("execute: #{matches.first.expression}", *(matches.first.params + [extra_arg].compact))
    end
  end

  module Define
    def step(expression, &block)
      step = Turnip::StepDefinition.new(expression, &block)
      send(:define_method, "match: #{expression}") { |description| step.match(description) }
      send(:define_method, "execute: #{expression}", &block)
    end
  end

  # The global step module
  module Steps
    extend Define
    include Execute

    def run_step(feature_file, step)
      begin
        step(step.description, step.extra_arg)
      rescue Turnip::Pending
        pending("No such step: '#{step.description}'")
      rescue StandardError => e
        e.backtrace.unshift "#{feature_file}:#{step.line}:in `#{step.description}'"
        raise e
      end
    end
  end

  class << self
    attr_accessor :type

    def run(feature_file)
      Turnip::Builder.build(feature_file).features.each do |feature|
        describe feature.name, feature.metadata_hash do
          before do
            # This is kind of a hack, but it will make RSpec throw way nicer exceptions
            example.metadata[:file_path] = feature_file

            feature.backgrounds.map(&:steps).flatten.each do |step|
              run_step(feature_file, step)
            end
          end
          feature.scenarios.each do |scenario|
            describe scenario.name, scenario.metadata_hash do
              it scenario.steps.map(&:description).join(' -> ') do
                scenario.steps.each do |step|
                  run_step(feature_file, step)
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
Turnip.step_dirs = ['spec']

RSpec::Core::Configuration.send(:include, Turnip::Loader)

RSpec.configure do |config|
  config.include Turnip::Steps
  config.pattern << ",**/*.feature"
end

self.extend Turnip::DSL
