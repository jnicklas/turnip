module Turnip
  module DSL
    def placeholder(name, &block)
      Turnip::Placeholder.add(name, &block)
    end

    def step(description, &block)
      Turnip::Steps.step(description, &block)
    end

    def steps_for(tag, &block)
      Turnip::StepModule.steps_for(tag, &block)
    end
  end
end
