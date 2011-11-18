module Turnip
  class StepDefinition
    class Match < Struct.new(:step_definition, :params, :block)
      def expression; step_definition.expression; end
    end

    class Pending < StandardError; end
    class Ambiguous < StandardError; end

    attr_reader :expression, :block

    class << self
      def execute(context, available_steps, step)
        match = find(available_steps, step.variations)
        params = match.params
        params << step.extra_arg if step.extra_arg
        context.instance_exec(*params, &match.block)
      rescue Pending
        context.pending "the step '#{step.description}' is not implemented"
      end

      def find(available_steps, step_variations)
        found = available_steps.map do |step|
          step.match(*step_variations)
        end.compact
        raise Pending, step_variations[0] if found.length == 0
        raise Ambiguous, step_variations[0] if found.length > 1
        found[0]
      end
    end

    def initialize(expression, &block)
      @expression = expression
      @block = block
    end

    def regexp
      @regexp ||= compile_regexp
    end

    def match(*step_variations)
      result = nil
      step_variations.flatten.each do |variant|
        result = variant.match(regexp)
        break if result
      end
      if result
        params = result.captures
        result.names.each_with_index do |name, index|
          params[index] = Turnip::Placeholder.apply(name.to_sym, params[index])
        end
        Match.new(self, params, block)
      end
    end

  protected

    OPTIONAL_WORD_REGEXP = /(\\\s)?\\\(([^)]+)\\\)(\\\s)?/
    PLACEHOLDER_REGEXP = /:([\w]+)/
    ALTERNATIVE_WORD_REGEXP = /(\w+)((\/\w+)+)/

    def compile_regexp
      regexp = Regexp.escape(expression)
      regexp.gsub!(OPTIONAL_WORD_REGEXP) do |_|
        [$1, $2, $3].compact.map { |m| "(#{m})?" }.join
      end
      regexp.gsub!(ALTERNATIVE_WORD_REGEXP) do |_|
        "(#{$1}#{$2.tr('/', '|')})"
      end
      regexp.gsub!(PLACEHOLDER_REGEXP) do |_|
        "(?<#{$1}>#{Placeholder.resolve($1.to_sym)})"
      end
      Regexp.new("^#{regexp}$")
    end
  end
end
