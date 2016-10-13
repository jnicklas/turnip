require "gherkin/parser"
require 'turnip/node/feature'

module Turnip
  class Builder
    def self.build(feature_file)
      parser = Gherkin::Parser.new
      result = parser.parse(File.read(feature_file))

      return nil unless result[:feature]
      Node::Feature.new(result[:feature])
    end
  end
end
