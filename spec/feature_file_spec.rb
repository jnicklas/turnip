require 'spec_helper'

describe Turnip::FeatureFile do
  let(:file_name) {File.expand_path('../examples/with_comments.feature', File.dirname(__FILE__))}
  let(:feature_file) {Turnip::FeatureFile.new(file_name)}
  
  describe '.feature_name' do
    it 'allows access to short name for the feature based on the file name' do
      feature_file.feature_name.should == 'with_comments'
    end
  end
  
  describe '.content' do
    it 'allows access to the content in the feature file' do
      feature_file.content.should be
    end
  end
end