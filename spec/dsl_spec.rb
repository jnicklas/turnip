require 'spec_helper'

describe Turnip::DSL do
  before do
    Turnip::StepModule.clear_module_registry
  end

  let(:context) { stub.tap { |s| s.extend(Turnip::DSL) }}

  describe '.steps_for' do
    it 'delegates to StepModule' do
      Turnip::StepModule.should_receive(:steps_for).with(:example)
      context.steps_for(:example) {}
    end
  end

  describe '.step' do
    context 'first step defined globally' do
      it 'creates a new global entry' do
        context.step('this is a test') {}
        Turnip::StepModule.should be_registered(:global)
      end
    end

    context 'all other steps defined globally' do
      it 'adds more steps to the :global step module' do
        context.step('this is a test') {}
        context.step('this is another test') {}
        Turnip::StepModule.module_registry[:global].first.step_module.steps.size.should eq(2)
      end
    end
  end

  describe '.placeholder' do
    before { Turnip::Placeholder.send(:placeholders).clear }

    it 'registers the placeholder globally' do
      context.placeholder('example') { true }
      Turnip::Placeholder.send(:placeholders).should have_key('example')
    end
  end
end
