module Turnip
  module DSL
    def placeholder(*name, &block)
      name.each do |n|
        Turnip::Placeholder.add(n, &block)
      end
    end

    def step(description, &block)
      Turnip::Steps.step(description, &block)
    end

    def steps_for(tag, &block)
      if tag.to_s == "global"
        warn "[Turnip] using steps_for(:global) is deprecated, add steps to Turnip::Steps instead"
        Turnip::Steps.module_eval(&block)
      else
        new_module = Module.new do
          singleton_class.send(:define_method, :tag) { tag }
          module_eval(&block)
          ::RSpec.configure { |c| c.include self, tag => true }
        end
        module_name = tag.to_s.split('_').map(&:capitalize).join + 'Steps'

        Object.const_set(module_name, new_module)
      end
    end
  end
end
