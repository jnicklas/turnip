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

      def use_steps(*tags)
        uses_steps.concat(tags)
      end

      def uses_steps
        @uses_steps ||= []
      end
    end

    class Entry < Struct.new(:for_taggings, :step_module, :uses_steps)
      def all_modules(already_visited = [])
        unless (already_visited & for_taggings).empty?
          []
        else
          already_visited.concat(for_taggings)
          uses_modules(already_visited) << step_module
        end
      end

      def uses_modules(already_visited)
        uses_steps.map do |uses_tag|
          StepModule.module_registry[uses_tag].map do |entry|
            entry.all_modules(already_visited)
          end
        end.flatten.uniq
      end
    end

    extend self

    def all_steps_for(*taggings)
      modules_for(*taggings).map do |step_module|
        step_module.steps
      end.flatten
    end

    def clear_module_registry
      module_registry.clear
    end

    def modules_for(*taggings)
      taggings.map do |tag|
        module_registry[tag].map do |entry|
          entry.all_modules
        end
      end.flatten.uniq
    end

    def module_registry
      @module_registry ||= Hash.new { |hash, key| hash[key] = [] }
    end

    def registered?(module_name)
      module_registry.has_key? module_name
    end

    def steps_for(*taggings, &block)
      anon = step_module(&block)

      entry = Entry.new(taggings, anon, anon.uses_steps)

      taggings.each do |tag|
        module_registry[tag] << entry
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
