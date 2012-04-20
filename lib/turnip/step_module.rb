require 'pathname'

module Turnip
  module StepModule
    module DSL
      def use_steps(*tags)
        Turnip::StepModule.modules_for(*tags).each do |mod|
          include mod
        end
      end
    end

    extend self

    def clear_module_registry
      module_registry.clear
    end

    def modules_for(*taggings)
      taggings.map do |tag|
        module_registry[tag]
      end.flatten.uniq
    end

    def module_registry
      @module_registry ||= Hash.new { |hash, key| hash[key] = [] }
    end

    def steps_for(tag, &block)
      anon = step_module(&block)

      module_registry[tag] << anon

      RSpec.configure do |config|
        config.include anon #, tag => true
      end
    end

    def step_module(&block)
      anon = Module.new
      anon.extend(Turnip::StepDSL)
      anon.extend(Turnip::StepModule::DSL)
      anon.module_eval(&block)
      anon
    end
  end
end
