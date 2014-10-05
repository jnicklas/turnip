module Turnip
  class StepDefinition
    class Match < Struct.new(:step_definition, :params, :block)
      def expression; step_definition.expression; end
      def method_name; step_definition.method_name; end
      def called_from; step_definition.called_from; end

      def trace
        %{  - "#{expression}" (#{called_from})}
      end
    end

    attr_reader :expression, :block, :method_name, :called_from

    def initialize(expression, method_name=nil, called_from=nil, &block)
      @expression = expression
      @method_name = method_name || expression
      @called_from = called_from
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
    ALTERNATIVE_WORD_REGEXP = /([[:alpha:]]+)((\/[[:alpha:]]+)+)/

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
