require "turnip"
require "rspec"

module Turnip
  module RSpec

    ##
    #
    # This module hooks Turnip into RSpec by duck punching the load Kernel
    # method. If the file is a feature file, we run Turnip instead!
    #
    module Loader
      def load(*a, &b)
        if a.first.end_with?('.feature')
          require_if_exists 'turnip_helper'
          require_if_exists 'spec_helper'

          Turnip::RSpec.run(a.first)
        else
          super
        end
      end

      private

      def require_if_exists(filename)
        require filename
      rescue LoadError => e
        # Don't hide LoadErrors raised in the spec helper.
        raise unless e.message.include?(filename)
      end
    end

    ##
    #
    # This module provides an improved method to run steps inside RSpec, adding
    # proper support for pending steps, as well as nicer backtraces.
    #
    module Execute
      include Turnip::Execute

      def run_step(feature_file, step)
        begin
          instance_eval <<-EOS, feature_file, step.line
            step(step)
          EOS
        rescue Turnip::Pending => e
          example = ::RSpec.current_example
          example.metadata[:line_number] = step.line
          example.metadata[:location] = "#{example.metadata[:file_path]}:#{step.line}"

          if ::RSpec.configuration.raise_error_for_unimplemented_steps
            e.backtrace.push "#{feature_file}:#{step.line}:in `#{step.description}'"
            raise
          end

          skip("No such step: '#{e}'")
        rescue StandardError, ::RSpec::Expectations::ExpectationNotMetError => e
          e.backtrace.push "#{feature_file}:#{step.line}:in `#{step.description}'"
          raise e
        end
      end
    end

    class << self
      def run(feature_file)
        feature = Turnip::Builder.build(feature_file)

        return nil if feature.nil?

        instance_eval <<-EOS, feature_file, feature.line
          context = ::RSpec.describe feature.name, feature.metadata_hash
          run_feature(context, feature, feature_file)
        EOS
      end

      private

      def run_feature(context, feature, filename)
        background_steps = feature.backgrounds.map(&:steps).flatten

        context.before do
          background_steps.each do |step|
            run_step(filename, step)
          end
        end

        feature.scenarios.each do |scenario|
          step_names = (background_steps + scenario.steps).map(&:to_s)
          description = step_names.join(' -> ')

          context.describe scenario.name, scenario.metadata_hash do
            instance_eval <<-EOS, filename, scenario.line
              it description do
                scenario.steps.each do |step|
                  run_step(filename, step)
                end
              end
            EOS
          end
        end
      end
    end
  end
end

::RSpec::Core::Configuration.send(:include, Turnip::RSpec::Loader)

::RSpec.configure do |config|
  config.include Turnip::RSpec::Execute, turnip: true
  config.include Turnip::Steps, turnip: true
  config.pattern += ',**/*.feature'
  config.add_setting :raise_error_for_unimplemented_steps, :default => false
end
