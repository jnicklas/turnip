module Turnip
  module Steps
    class Pending < StandardError; end
    class Ambiguous < StandardError; end

    extend self

    def execute_step(context, description)
      context.instance_eval(&find_step(description))
    rescue Pending
      context.pending "the step '#{description}' is not implemented"
    end

    def add_step(description, &block)
      steps << [description, block]
    end

    def find_step(description)
      found = steps.select do |step|
        step.first == description
      end
      raise Pending, description if found.length == 0
      raise Ambiguous, description if found.length > 1
      found[0][1]
    end

    def steps
      @steps ||= []
    end
  end
end
