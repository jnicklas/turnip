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
          match %r((?:"([^"]*)"|'([^']*)'|([[:alnum:]_-]+))) do |first, second, third|
            first or second or third
          end
        end
      end
    end

    def initialize(name, &block)
      @name = name
      @matches = []
      instance_eval(&block)
    end

    def apply(value)
      match, params = find_match(value)
      if match and match.block then match.block.call(*params) else value end
    end

    def match(regexp, &block)
      @matches << Match.new(regexp, block)
    end

    def regexp
      Regexp.new(@matches.map(&:regexp).join('|'))
    end

  private

    def find_match(value)
      @matches.each do |m|
        result = value.scan(m.regexp)
        return m, result.flatten unless result.empty?
      end
      nil
    end
  end
end
