require 'spec_helper'

describe Turnip::DSL do
  let(:context) { stub.tap { |s| s.extend(Turnip::DSL) }}

  describe '.steps_for' do
    pending 'adds the module to RSpec' do
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
