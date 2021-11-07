require 'turnip/node/base'
require 'turnip/node/tag'

module Turnip
  module Node
    #
    # @note Example metadata generated by Gherkin
    #
    #     {
    #       type: :Examples,
    #       tags: [], # Array of Tag
    #       location: { line: 10, column: 3 },
    #       keyword: "Examples",
    #       name: "Example Description",
    #       tableHeader: {},
    #       tableBody: {}
    #     }
    #
    class Example < Base
      include HasTags

      def keyword
        @raw.keyword
      end

      def name
        @raw.name
      end

      def description
        @raw.description
      end

      #
      # @note
      #
      #   Examples:
      #   | monster | hp |
      #   | slime   | 10 | => [ 'monster', 'hp' ]
      #   | daemon  | 70 |
      #
      # @return [Array]
      #
      def header
        @header ||= @raw.parameter_row.cells.map { |c| c.value }
      end

      #
      # @note
      #
      #   Examples:
      #   | monster | hp |
      #   | slime   | 10 | => [ ['slime', '10'], ['daemon', '70'] ]
      #   | daemon  | 70 |
      #
      # @return [Array]
      #
      def rows
        @rows ||= @raw.argument_rows.map do |row|
          row.cells.map { |c| c.value }
        end
      end
    end
  end
end
