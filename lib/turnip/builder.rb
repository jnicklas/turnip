require "gherkin/gherkin"
require 'turnip/node/feature'

module Turnip
  class Builder
    def self.build(feature_file)
      messages = Gherkin::Gherkin.from_paths([feature_file], include_source: false, include_pickles: false)
      message = messages.first or return nil
      gherkinDocument = message.gherkinDocument or return nil
      result = gherkinDocument.to_hash or return nil
      feature = result[:feature] or return nil
      Node::Feature.new(feature)
    end
  end
end
