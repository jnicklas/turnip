require 'spec_helper'

describe Turnip::ScenarioContext do
  let(:context) { Turnip::ScenarioContext.new(feature, scenario) }
  let(:feature) { stub(:active_tags => feature_tags) }
  let(:feature_tags) { %w(feature both) }
  let(:scenario) { stub(:active_tags => scenario_tags) }
  let(:scenario_tags) { %w(scenario both) }
  let(:unique_tags) { (feature_tags + scenario_tags).uniq }

  describe '#initialize' do
    let(:feature) { stub }
    let(:scenario) { stub }

    it 'keeps track of the feature' do
      Turnip::ScenarioContext.new(feature, scenario).feature.should eq(feature)
    end

    it 'keeps track of the scenario' do
      Turnip::ScenarioContext.new(feature, scenario).scenario.should eq(scenario)
    end
  end

  describe '#available_background_steps' do
    it 'gathers the steps for the feature tags' do
      Turnip::StepModule.should_receive(:all_steps_for).with(*feature_tags)
      context.available_background_steps
    end
  end

  describe '#available_scenario_steps' do
    it 'gathers the steps for the unique scenario and feature tags' do
      Turnip::StepModule.should_receive(:all_steps_for).with(*unique_tags)
      context.available_scenario_steps
    end
  end

  describe '#backgrounds' do
    it 'delegates to the feature' do
      feature.should_receive :backgrounds
      context.backgrounds
    end
  end

  describe '#modules' do
    it 'gathers the modules for the unique scenario and feature tags' do
      Turnip::StepModule.should_receive(:modules_for).with(*unique_tags)
      context.modules
    end
  end
end
