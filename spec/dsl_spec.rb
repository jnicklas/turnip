require 'spec_helper'

describe Turnip::DSL do
  let(:context) { double.tap { |s| s.extend(Turnip::DSL) }}
  let(:an_object) { Object.new.tap { |o| o.extend(Turnip::Execute) }}
  describe '.steps_for' do
    before do
      ::RSpec.stub(:configure)
    end

    it 'creates a new module and adds steps to it' do
      mod = context.steps_for(:foo) do
        step("foo") { "foo" }
      end
      an_object.extend mod
      an_object.step("foo").should == "foo"
    end

    it 'remembers the name of the module' do
      mod = context.steps_for(:foo) {}
      mod.tag.should == :foo
    end

    it 'tells RSpec to include the module' do
      config = double
      RSpec.should_receive(:configure).and_yield(config)
      config.should_receive(:include)

      context.steps_for(:foo) {}
    end

    it 'warns of deprecation when called with :global' do
      context.should_receive(:warn)
      mod = context.steps_for(:global) do
        step("foo") { "foo" }
      end
      an_object.extend Turnip::Steps
      an_object.step("foo").should == "foo"
    end
  end

  describe '.step' do
    it 'adds steps to Turnip::Steps' do
      context.step('this is a test') { "foo" }
      context.step('this is another test') { "bar" }
      an_object.extend Turnip::Steps
      an_object.step("this is a test").should == "foo"
    end
  end

  describe '.placeholder' do
    before { Turnip::Placeholder.send(:placeholders).clear }

    it 'registers the placeholder globally' do
      context.placeholder('example') { true }
      Turnip::Placeholder.send(:placeholders).should have_key('example')
    end

    it 'registers the multi placeholder globally' do
      context.placeholder('example_1', 'example_2') { true }
      Turnip::Placeholder.send(:placeholders).should have_key('example_1')
      Turnip::Placeholder.send(:placeholders).should have_key('example_2')
    end
  end
end
