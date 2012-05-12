module Turnip
  class StepDefinition
    class Match < Struct.new(:step_definition, :params, :block)
      def expression; step_definition.expression; end
    end

    attr_reader :expression, :block

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
        @placeholder_names.each_with_index do |name, index|
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
      @placeholder_names = []
      regexp = Regexp.escape(expression)
      regexp.gsub!(PLACEHOLDER_REGEXP) do |_|
        @placeholder_names << "#{$1}"
        "(?<#{$1}>#{Placeholder.resolve($1.to_sym)})"
      end
      regexp.gsub!(OPTIONAL_WORD_REGEXP) do |_|
        [$1, $2, $3].compact.map { |m| "(?:#{m})?" }.join
      end
      regexp.gsub!(ALTERNATIVE_WORD_REGEXP) do |_|
        "(?:#{$1}#{$2.tr('/', '|')})"
      end
      Regexp.new("^#{regexp}$")
    end
  end
end
