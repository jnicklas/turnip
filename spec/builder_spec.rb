require 'spec_helper'

describe Turnip::Builder do
  context "with scenario outlines" do
    let(:feature_file) { File.expand_path('../examples/scenario_outline.feature', File.dirname(__FILE__)) }
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

  context "with example tables in scenario outlines" do
    let(:feature_file) { File.expand_path('../examples/scenario_outline_table_substitution.feature', File.dirname(__FILE__)) }
    let(:builder) { Turnip::Builder.build(feature_file) }
    let(:feature) { builder.features.first }

    it "replaces placeholders in tables in steps" do
      feature.scenarios[0].steps.map(&:description).should eq([
        "there is a monster with hitpoints:",
        "I attack the monster and do 13 points damage",
        "the monster should be dead"
      ])
      table = feature.scenarios[0].steps[0].extra_args.find {|a| a.instance_of?(Turnip::Table)}
      table.hashes[0]['hit_points'].should == '10'
      table = feature.scenarios[1].steps[0].extra_args.find {|a| a.instance_of?(Turnip::Table)}
      table.hashes[0]['hit_points'].should == '8'
    end

  end
end
