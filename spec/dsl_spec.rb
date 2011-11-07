require 'spec_helper'

describe Turnip::DSL do
  before do
    @context = stub
    @context.extend(Turnip::DSL)
  end

  describe '#steps_for' do
    it 'delegates to StepModule' do
      Turnip::StepModule.should_receive(:steps_for).with(:example)
      @context.steps_for(:example) {}
    end
  end
end
