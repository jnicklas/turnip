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
          begin
            require 'spec_helper'
          rescue LoadError
          end
          Turnip.load_steps
          Turnip::RSpec.run(a.first)
        else
          super
        end
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
          pending("No such step: '#{step.description}'")
        rescue StandardError => e
          e.backtrace.unshift "#{feature_file}:#{step.line}:in `#{step.description}'"
          raise e
        end
      end
    end

    class << self
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
end

::RSpec::Core::Configuration.send(:include, Turnip::RSpec::Loader)

::RSpec.configure do |config|
  config.include Turnip::RSpec::Execute
  config.include Turnip::Steps
  config.pattern << ",**/*.feature"
end
