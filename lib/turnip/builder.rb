require "gherkin"
require 'turnip/node/feature'

module Turnip
  class Builder
    def self.build(feature_file)
      messages = Gherkin.from_paths(
        [feature_file],
        include_source: false,
        include_gherkin_document: true,
        include_pickles: false
      )
      result = messages.first&.gherkin_document&.to_hash

      return nil if result.nil? || result[:feature].nil?
      Node::Feature.new(result[:feature])
    end
  end
end
