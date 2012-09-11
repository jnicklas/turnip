require "turnip"
require "rspec"
require_relative 'monkey_rspec_example_group'

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
        rescue Turnip::Pending
          pending("No such step: '#{step}'")
        rescue StandardError => e
          e.backtrace.push "#{feature_file}:#{step.line}:in `#{step.description}'"
          raise e
        end
      end
    end

    class << self
      def run(feature_file)
        Turnip::Builder.build(feature_file).features.each do |feature|
          describe feature.name, feature.metadata_hash do
            prepare_feature(feature, feature_file)
            run_scenarios(feature, feature_file)
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
