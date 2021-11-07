require 'turnip/node/base'
require 'turnip/node/scenario'
require 'turnip/node/scenario_outline'
require 'turnip/node/background'

module Turnip
  module Node
    class ScenarioGroupDefinition < Base
      def name
        @raw.name
      end

      def keyword
        @raw.keyword
      end

      def description
        @raw.description
      end

      def backgrounds
        @backgrounds ||= children.select do |c|
          c.is_a?(Background)
        end
      end

      def scenarios
        @scenarios ||= children.map do |c|
          case c
          when Scenario
            c
          when ScenarioOutline
            c.to_scenarios
          end
        end.flatten.compact
      end
    end
  end
end
