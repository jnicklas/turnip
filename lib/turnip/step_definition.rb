module Turnip
  class StepDefinition
    class Match < Struct.new(:params, :block); end

    attr_reader :expression, :block

    def initialize(expression, &block)
      @expression = expression
      @block = block
    end

    def regexp
      @regexp ||= compile_regexp
    end

    def match(description)
      result = description.scan(regexp)
      unless result.empty?
        Match.new([result.first].flatten.compact, block)
      end
    end

  protected

    def compile_regexp
      regexp = Regexp.escape(expression)
      regexp = expression.gsub(/:[\w]+/) do |match|
        %((?:"([^"]+)"|([a-zA-Z0-9_-]+)))
      end
      Regexp.new("^#{regexp}$")
    end
  end
end
