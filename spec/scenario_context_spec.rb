require 'spec_helper'

describe Turnip::ScenarioContext do
  let(:context) { Turnip::ScenarioContext.new(world) }
  let(:world) { stub }

  describe '#initialize' do
    it 'keeps track of the world' do
      context.world.should eq(world)
    end
  end

  describe '#enable_tags' do

    let(:tags) { [:tag1, :tag2, :tag1] }
    let(:some_module) { Module.new }

    before do
      Turnip::StepModule.should_receive(:modules_for).with(*tags).and_return([some_module])
      context.enable_tags(*tags)
    end

    it 'loads modules into the world' do
      world.should be_kind_of(some_module)
    end

    it 'keeps unique tags' do
      context.available_tags.should == [:tag1, :tag2]
    end

  end

  describe '#disable_tags' do

    let(:tags) { [:tag1, :tag2] }

    before do
      context.enable_tags(*tags)
    end

    context 'one tag' do
      it 'disables the tag' do
        context.disable_tags(:tag1)
        context.available_tags.should == [:tag2]
      end
    end

    context 'two tags' do
      it 'disables the tags' do
        context.disable_tags(:tag1, :tag2)
        context.available_tags.should == []
      end
    end

  end

  describe '#available_steps' do
    it 'gathers the steps for the available tags' do
      tags = [stub]
      context.enable_tags(*tags)
      Turnip::StepModule.should_receive(:all_steps_for).with(*tags)
      context.available_steps
    end
  end

end
