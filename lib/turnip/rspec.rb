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
          step(step)
        rescue Turnip::Pending => e
          # This is kind of a hack, but it will make RSpec throw way nicer exceptions
          example = Turnip::RSpec.fetch_current_example(self)
          example.metadata[:line_number] = step.line
          pending("No such step: '#{e}'")
        rescue StandardError => e
          e.backtrace.push "#{feature_file}:#{step.line}:in `#{step.description}'"
          raise e
        end
      end
    end

    class << self
      def fetch_current_example(context)
        if ::RSpec.respond_to?(:current_example)
          ::RSpec.current_example
        else
          context.example
        end
      end

      def run(feature_file)
        Turnip::Builder.build(feature_file).features.each do |feature|
          ::RSpec.describe feature.name, feature.metadata_hash do
            before do
              example = Turnip::RSpec.fetch_current_example(self)
              # This is kind of a hack, but it will make RSpec throw way nicer exceptions
              example.metadata[:file_path] = feature_file

              path = Pathname.new(feature_file)
              default_steps_file = File.join(path.dirname, 'steps', path.basename.to_s.sub('.feature', '_steps.rb'))
              default_steps_module = [path.basename.to_s.sub('.feature', '').split('_').collect(&:capitalize), 'Steps'].join

              if File.exists?(default_steps_file)
                require default_steps_file
                if Module.const_defined?(default_steps_module)
                  extend Module.const_get(default_steps_module)
                end
              end

              feature.backgrounds.map(&:steps).flatten.each do |step|
                run_step(feature_file, step)
              end
            end
            feature.scenarios.each do |scenario|
              instance_eval <<-EOS, feature_file, scenario.line
                describe scenario.name, scenario.metadata_hash do it(scenario.steps.map(&:description).join(' -> ')) do
                    scenario.steps.each do |step|
                      run_step(feature_file, step)
                    end
                  end
                end
              EOS
            end
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
  config.pattern << ",**/*.feature"
end
