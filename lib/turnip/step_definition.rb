module Turnip
  class StepDefinition
    class Match < Struct.new(:step_definition, :params, :block)
      def expression; step_definition.expression; end
      def options; step_definition.options; end
    end

    class Pending < StandardError; end
    class Ambiguous < StandardError; end

    attr_reader :expression, :block, :options

    class << self
      def execute(context, step)
        match = find(step.description, context.example.metadata)
        params = match.params
        params << step.extra_arg if step.extra_arg
        context.instance_exec(*params, &match.block)
      rescue Pending
        context.pending "the step '#{step.description}' is not implemented"
      end

      def add(expression, options={}, &block)
        all << StepDefinition.new(expression, options, &block)
      end

      def find(description, metadata={})
        found = all.map do |step|
          step.match(description, metadata)
        end.compact
        raise Pending, description if found.length == 0
        raise Ambiguous, description if found.length > 1
        found[0]
      end

      def all
        @all ||= []
      end
    end

    def initialize(expression, options={}, &block)
      @expression = expression
      @block = block
      @options = options
    end

    def regexp
      @regexp ||= compile_regexp
    end

    def match(description, metadata={})
      if matches_metadata?(metadata)
        result = description.match(regexp)
        if result
          params = result.captures
          result.names.each_with_index do |name, index|
            params[index] = Turnip::Placeholder.apply(name.to_sym, params[index])
          end
          Match.new(self, params, block)
        end
      end
    end

  protected

    def matches_metadata?(metadata)
      not options[:for] or [options[:for]].flatten.any? { |option| metadata.has_key?(option) }
    end

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
