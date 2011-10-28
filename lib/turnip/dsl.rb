module Turnip
  module DSL
    def step(description, &block)
      Turnip::StepDefinition.add(description, &block)
    end

    def placeholder(name, &block)
      Turnip::Placeholder.add(name, &block)
    end
  end
end
