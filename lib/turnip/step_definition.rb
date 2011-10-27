module Turnip
  class StepDefinition
    class Match < Struct.new(:params, :block); end
    class Pending < StandardError; end
    class Ambiguous < StandardError; end

    attr_reader :expression, :block

    class << self
      def execute(context, description)
        match = find(description)
        context.instance_exec(*match.params, &match.block)
      rescue Pending
        context.pending "the step '#{description}' is not implemented"
      end

      def add(expression, &block)
        steps << StepDefinition.new(expression, &block)
      end

      def find(description)
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

    def initialize(expression, &block)
      @expression = expression
      @block = block
    end

    def regexp
      @regexp ||= compile_regexp
    end

    def match(description)
      result = description.match(regexp)
      if result
        params = result.captures
        result.names.each_with_index do |name, index|
          params[index] = Turnip::Placeholder.apply(name.to_sym, params[index])
        end
        Match.new(params, block)
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
      regexp.gsub!(PLACEHOLDER_REGEXP) do |_|
        "(?<#{$1}>#{Placeholder.resolve($1.to_sym)})"
      end
      regexp.gsub!(ALTERNATIVE_WORD_REGEXP) do |_|
        "(?:#{$1}#{$2.tr('/', '|')})"
      end
      Regexp.new("^#{regexp}$")
    end
  end
end
