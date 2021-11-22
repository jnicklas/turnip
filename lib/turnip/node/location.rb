module Turnip
  module Node
    #
    # @note Location metadata generated by Gherkin
    #
    #     {
    #       line: 10,
    #       column: 3
    #     }
    #
    class Location
      attr_reader :line,
                  :column

      def initialize(line, column)
        @line = line
        @column = column
      end
    end

    module HasLocation
      #
      # @return [Location]
      #
      def location
        @location ||= Location.new(@raw.source_line, @raw.source_column)
      end

      def line
        location.line
      end
    end
  end
end
