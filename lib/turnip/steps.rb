module Turnip
  module Steps
    class Pending < StandardError; end
    class Ambiguous < StandardError; end

    extend self

    def execute_step(context, description)
      step = find_step(description)
      context.instance_exec(*step[:params], &step[:block])
    rescue Pending
      context.pending "the step '#{description}' is not implemented"
    end

    def add_step(description, &block)
      steps << [description, block]
    end

    def find_step(description)
      found = steps.map do |step|
        match(description, *step)
      end.compact
      raise Pending, description if found.length == 0
      raise Ambiguous, description if found.length > 1
      found[0]
    end

    def match(description, step, block)
      step = Regexp.escape(step)
      step = step.gsub(/:[\w]+/) do |match|
        %((?:"([^"]+)"|([a-zA-Z0-9_-]+)))
      end
      regexp = Regexp.new("^#{step}$")
      result = description.scan(regexp)
      unless result.empty?
        { :block => block, :params => [result.first].flatten.compact }
      end
    end

    def steps
      @steps ||= []
    end
  end
end
