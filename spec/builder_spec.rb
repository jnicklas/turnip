require 'spec_helper'

describe Turnip::Builder do
  context "with scenario outlines" do
    let(:feature_file) { Turnip::FeatureFile.new(File.expand_path('../examples/scenario_outline.feature', File.dirname(__FILE__))) }
    let(:builder) { Turnip::Builder.build(feature_file) }
    let(:feature) { builder.features.first }


    it "extracts scenarios" do
      feature.scenarios.map(&:name).should eq([
        'a simple outline',
        'a simple outline'
      ])
    end

    it "replaces placeholders in steps" do
      feature.scenarios[0].steps.map(&:description).should eq([
        "there is a monster with 10 hitpoints",
        "I attack the monster and do 13 points damage",
        "the monster should be dead"
      ])
      feature.scenarios[1].steps.map(&:description).should eq([
        "there is a monster with 8 hitpoints",
        "I attack the monster and do 5 points damage",
        "the monster should be alive"
      ])
    end
  end
  
  describe "taggings" do
    let(:feature_file) { Turnip::FeatureFile.new(File.expand_path('../examples/autoload_steps.feature', File.dirname(__FILE__))) }
    let(:builder) { Turnip::Builder.build(feature_file) }
    let(:feature) { builder.features.first }
    
    context "for features" do
      it 'should automatically include the :global tag for features' do
        feature.active_tags.should include(:global)
      end
      
      it 'should automatically include the feature name tag for features' do
        feature.active_tags.should include(:autoload_steps)
      end
    end
    
    context "for scenarios" do
      it 'should only include scenario tags' do
        feature.scenarios.first.active_tags.should eq([:scenario_tag])
      end
    end
    
    context "autotag features disabled" do
      before(:each) { Turnip::Config.autotag_features = false }
      after(:each) { Turnip::Config.autotag_features = true }
      
      let(:feature_file) { Turnip::FeatureFile.new(File.expand_path('../examples/autoload_steps.feature', File.dirname(__FILE__))) }
      let(:builder) { Turnip::Builder.build(feature_file) }
      let(:feature) { builder.features.first }
      
      it 'should automatically include the :global tag for features' do
        feature.active_tags.should include(:global)
      end
      
      it 'should not automatically include the feature name tag for features' do
        feature.active_tags.should_not include(:autoload_steps)
      end
    end
  end
end
