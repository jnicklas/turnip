require 'pathname'

module Turnip
  module StepModule
    module DSL
      def placeholder(name, &block)
        Turnip::Placeholder.add(name, &block)
      end

      def step(description, &block)
        steps << Turnip::StepDefinition.new(description, &block)
      end

      def steps
        @steps ||= []
      end
    end

    extend self

    def clear_module_registry
      module_registry.clear
    end

    def load_steps
      Turnip::Config.step_dirs.each do |dir|
        Pathname.glob(Pathname.new(dir) + '**' + "*steps.rb").each do |step_file|
          load step_file, true
        end
      end
    end

    def module_registry
      @module_registry ||= Hash.new { |hash, key| hash[key] = [] }
    end

    def registered?(module_name)
      module_registry.has_key? module_name
    end

    def steps_for(*taggings, &block)
      anon = step_module(&block)
      taggings.each do |tag|
        module_registry[tag] << anon
      end
    end

    def step_module(&block)
      anon = Module.new
      anon.extend(Turnip::StepModule::DSL)
      anon.module_eval(&block)
      anon
    end
  end
end
