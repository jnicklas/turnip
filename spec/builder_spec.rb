require 'spec_helper'

describe Turnip::Builder do
  let(:builder) { Turnip::Builder.build(feature_file) }
  let(:feature) { builder.features.first }

  context 'simple scenarios' do
    let(:feature_file) { File.expand_path('../examples/simple_feature.feature', File.dirname(__FILE__)) }
    let(:steps) { feature.scenarios.first.steps }

    it 'extracts step description' do
      steps.map(&:description).should eq([
        'there is a monster',
        'I attack it',
        'it should die'
      ])
    end

    it 'extracts step line' do
      steps.map(&:line).should eq([3, 4, 5])
    end

    it 'extracts step keyword' do
      steps.map(&:keyword).should eq(['Given ', 'When ', 'Then '])
    end

    it 'extracts full description' do
      steps.map(&:to_s).should eq([
        'Given there is a monster',
        'When I attack it',
        'Then it should die'
      ])
    end
  end

  context "with scenario outlines" do
    let(:feature_file) { File.expand_path('../examples/scenario_outline.feature', File.dirname(__FILE__)) }

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

  context 'with example multiline in scenario outlines' do
    let(:feature_file) { File.expand_path('../examples/scenario_outline_multiline_string_substitution.feature', File.dirname(__FILE__)) }
    let(:steps) { feature.scenarios[1].steps }

    it 'replaces placeholders in multiline in steps' do
      steps.map(&:description).should eq([
        'there is a monster called "John Smith"',
        'the monster introduced himself:'
      ])

      multiline = steps[1].extra_args.first
      multiline.should eq %q(Ahhhhhhh! i'm "John Smith"!)
    end
  end
end
