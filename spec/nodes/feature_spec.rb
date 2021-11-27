require 'spec_helper'

describe Turnip::Node::Feature do
  let(:feature) { Turnip::Builder.build(feature_file) }

  context 'a file that specifies a language' do
    let(:feature_file) { File.expand_path('../../examples/specific_language.feature', __dir__) }

    it 'extracts the language' do
      feature.language.should eq 'en-au'
    end

  end
end
