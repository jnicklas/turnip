require 'turnip/node/location'

module Turnip
  module Node
    class Base
      include HasLocation

      attr_reader :raw

      def initialize(raw)
        @raw = raw
      end
    end
  end
end
