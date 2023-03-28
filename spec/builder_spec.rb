require 'spec_helper'

describe Turnip::Builder do
  let(:feature) { Turnip::Builder.build(feature_file) }

  context 'blank file' do
    let(:feature_file) { File.expand_path('../examples/blank.feature', File.dirname(__FILE__)) }

    it 'has no feature' do
      feature.should eq nil
    end

  end

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

  context 'with tags' do
    let(:feature_file) { File.expand_path('../examples/tags.feature', File.dirname(__FILE__)) }

    it 'extracts tags' do
      expect(feature.tags[0]).to be_instance_of Turnip::Node::Tag
      expect(feature.scenarios[0].tags[0].name).to eq 'cool'
      expect(feature.scenarios[1].tag_names).to eq ['stealthy', 'wicked']
      expect(feature.scenarios[2].tag_names).to eq ['variety']
      expect(feature.scenarios[3].tag_names).to eq ['variety']
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

  context "with example scenario name in scenario outlines" do
    let(:feature_file) { File.expand_path('../examples/scenario_outline_scenario_name_substitution.feature', File.dirname(__FILE__)) }

    it "replaces placeholders in scenario name" do
      feature.scenarios.map(&:name).should eq([
        "a monster introduced himself as John",
        'a monster introduced himself as "John Smith"',
        %(a monster introduced himself as "O'Flannahan")
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
      table = feature.scenarios[0].steps[0].argument
      table.hashes[0]['hit_points'].should eq '10'
      table = feature.scenarios[1].steps[0].argument
      table.hashes[0]['hit_points'].should eq '8'
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

      multiline = steps[1].argument
      multiline.should eq %q(Ahhhhhhh! i'm "John Smith"!)
    end
  end
end
