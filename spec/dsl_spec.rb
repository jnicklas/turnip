require 'spec_helper'

describe Turnip::DSL do
  before do
    @context = stub
    @context.extend(Turnip::DSL)
  end

  describe '#step' do
    it 'adds a step to the list of step definitions' do
      Turnip::StepDefinition.should_receive(:add).with('this is a :thing test', {})
      @context.step 'this is a :thing test'
    end

    it 'sends through options' do
      Turnip::StepDefinition.should_receive(:add).with('foo', {:for => [:monkey]})
      @context.step 'foo', :for => [:monkey]
    end
  end

  describe '#steps_for' do
    it 'executes the given block and adds steps with for set' do
      Turnip::StepDefinition.should_receive(:add).with('foo', {:for => [:gorilla]})
      @context.steps_for :gorilla do
        @context.step 'foo'
      end
    end

    it 'combines step for option and block options' do
      Turnip::StepDefinition.should_receive(:add).with('foo', {:for => [:a, :b, :gorilla]})
      @context.steps_for :gorilla do
        @context.step 'foo', :for => [:a, :b]
      end
    end

    it 'can be nested' do
      Turnip::StepDefinition.should_receive(:add).with('foo', {:for => [:c, :b, :a]})
      @context.steps_for :a do
        @context.steps_for :b do
          @context.step 'foo', :for => :c
        end
      end
    end
  end

  describe '#placeholder' do
    it 'adds a placeholder to the list of placeholders' do
      @context.placeholder :quox do
        match(/foo/) { 'bar' }
      end
      Turnip::Placeholder.apply(:quox, 'foo').should == 'bar'
    end
  end
end
