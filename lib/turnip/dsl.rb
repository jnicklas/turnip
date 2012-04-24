module Turnip
  module DSL
    def placeholder(name, &block)
      Turnip::Placeholder.add(name, &block)
    end

    def step(description, &block)
      Turnip::Steps.step(description, &block)
    end

    def steps_for(tag, &block)
      if tag.to_s == "global"
        warn "[Turnip] using steps_for(:global) is deprecated, add steps to Turnip::Steps instead"
        Turnip::Steps.module_eval(&block)
      else
        mod = Module.new
        mod.extend Turnip::Define
        mod.module_eval(&block)
        RSpec.configure { |c| c.include mod, tag => true }
      end
    end
  end
end
