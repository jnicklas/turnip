module Turnip
  module Define
    def step(method_name=nil, expression, &block)
      if method_name and block
        raise ArgumentError, "can't specify both method name and a block for a step"
      end
      step = Turnip::StepDefinition.new(expression, method_name, caller.first, &block)
      send(:define_method, "match: #{expression}") { |description| step.match(description) }
      send(:define_method, expression, &block) if block
    end
  end
end
