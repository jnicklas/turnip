require "gherkin/parser"
require 'turnip/node/feature'

module Turnip
  class Builder

    attr_reader :features

    class << self
      def build(feature_file)
        Turnip::Builder.new.tap do |builder|
          parser = Gherkin::Parser.new
          result = parser.parse(File.read(feature_file))
          builder.build(result)
        end
      end
    end

    def initialize
      @features = []
    end

    def build(attributes)
      return unless attributes[:feature]

      @features << Node::Feature.new(attributes[:feature])
    end
  end
end
