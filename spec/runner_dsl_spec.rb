require 'spec_helper'

describe Turnip::RunnerDSL do
  describe '#step' do
    include Turnip::RunnerDSL

    it 'runs the step' do
      self.turnip_runner = Class.new do
        attr_accessor :args
        def run_steps(steps)
          self.args << steps
        end
      end.new
      self.turnip_runner.args = []

      step('description', 'extra_arg')
      step = turnip_runner.args.flatten.first
      step.should be_kind_of(Turnip::Builder::Step)
      step.description.should eq('description')
      step.extra_arg.should eq('extra_arg')
    end
  end

  describe '#enable_steps_for' do
    include Turnip::RunnerDSL

    it 'enables the tag' do
      self.turnip_context = stub
      turnip_context.should_receive(:enable_tags).with(:tag)
      enable_steps_for('tag')
    end
  end

  describe '#disable_steps_for' do
    include Turnip::RunnerDSL

    it 'disables the tag' do
      self.turnip_context = stub
      turnip_context.should_receive(:disable_tags).with(:tag)
      disable_steps_for('tag')
    end
  end
end
