require "cuke_modeler"
require 'turnip/node/feature'

module Turnip
  class Builder
    def self.build(feature_file)
      feature_file = CukeModeler::FeatureFile.new(feature_file)

      return nil unless feature_file.feature
      Node::Feature.new(feature_file.feature)
    end
  end
end
