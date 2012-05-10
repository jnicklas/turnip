module Turnip
  module Define
    def step(expression, &block)
      step = Turnip::StepDefinition.new(expression, &block)
      send(:define_method, "match: #{expression}") { |description| step.match(description) }
      send(:define_method, expression, &block)
    end
  end
end
