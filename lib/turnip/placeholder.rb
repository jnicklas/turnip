module Turnip
  class Placeholder
    class Match < Struct.new(:regexp, :block);end

    class << self
      def add(name, &block)
        placeholders[name] = Placeholder.new(name, &block)
      end

      def resolve(name)
        find(name).regexp
      end

      def apply(name, value)
        find(name).apply(value)
      end

      def find(name)
        placeholders[name] or default
      end

    private

      def placeholders
        @placeholders ||= {}
      end

      def default
        @default ||= new(:default) do
          default do |value|
            value
          end
        end
      end
    end

    def initialize(name, &block)
      @name = name
      @matches = []
      @default = nil
      instance_eval(&block)
    end

    def apply(value)
      match, params = find_match(value)
      if match and match.block then match.block.call(*params) else value end
    end

    def match(regexp, &block)
      @matches << Match.new(regexp, block)
    end

    def default(&block)
      @default ||= Match.new(
        %r{['"]?((?:(?<=")[^"]*)(?=")|(?:(?<=')[^']*(?='))|(?<!['"])[[:alnum:]_-]+(?!['"]))['"]?},
        block
      )
    end

    def regexp
      Regexp.new(placeholder_matches.map(&:regexp).join('|'))
    end

  private

    def find_match(value)
      @matches.each do |m|
        result = value.scan(m.regexp)
        return m, result.flatten unless result.empty?
      end

      #
      # value is one of the following:
      #
      #  %{Jhon Doe}
      #  %{"Jhon Doe"}
      #  %{'Jhon Doe'}
      #
      # In any case, it passed to the step block in the state without quotes
      return @default, value.sub(/^(["'])([^\1]*)\1$/, '\2')
    end

    def placeholder_matches
      matches = @matches
      matches += [@default] if @default
      matches
    end
  end
end
