module Turnip
  module Steps
    class Pending < StandardError; end
    class Ambiguous < StandardError; end

    extend self

    def execute_step(context, description)
      match = find_step(description)
      context.instance_exec(*match.params, &match.block)
    rescue Pending
      context.pending "the step '#{description}' is not implemented"
    end

    def add_step(expression, &block)
      steps << StepDefinition.new(expression, &block)
    end

    def find_step(description)
      found = steps.map do |step|
        step.match(description)
      end.compact
      raise Pending, description if found.length == 0
      raise Ambiguous, description if found.length > 1
      found[0]
    end

    def steps
      @steps ||= []
    end
  end
end
