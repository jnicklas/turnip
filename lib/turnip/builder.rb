require "gherkin/gherkin"
require 'turnip/node/feature'

module Turnip
  class Builder
    def self.build(feature_file)
      messages = Gherkin::Gherkin.from_paths([feature_file], include_source: false, include_pickles: false)
      result = messages.first&.gherkinDocument&.to_hash

      return nil if result.nil? || result[:feature].nil?
      Node::Feature.new(result[:feature])
    end
  end
end
