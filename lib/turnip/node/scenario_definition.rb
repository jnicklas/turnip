require 'turnip/node/base'
require 'turnip/node/step'

module Turnip
  module Node
    class ScenarioDefinition < Base
      def name
        @raw[:name]
      end

      def keyword
        @raw[:keyword]
      end

      def description
        @raw[:description]
      end

      def steps
        @steps ||= @raw[:steps].map do |step|
          Step.new(step)
        end
      end
    end
  end
end
