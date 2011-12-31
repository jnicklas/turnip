require 'spec_helper'

describe Turnip::ScenarioRunner do
  let(:runner) { Turnip::ScenarioRunner.new(world) }
  let(:world) { Object.new }

  describe '#initialize' do
    it 'keeps track of the world' do
      Turnip::ScenarioRunner.new(world).world.should eq(world)
    end
  end

  describe '#load' do
    let(:context) { stub(:modules => [some_module]) }
    let(:some_module) { Module.new }

    it 'is chainable' do
      runner.load(context).should eq(runner)
    end

    it 'keeps track of the scenario context' do
      runner.load(context).context.should eq(context)
    end

    it 'loads the given modules into the world' do
      runner.load(context).world.should be_kind_of(some_module)
    end
  end

  describe '#run' do
    it 'iterates over the background steps' do
      runner.context = stub(:backgrounds => (0..2).map { stub(:steps => [stub]) },
                                 :available_background_steps => [],
                                 :available_scenario_steps => [],
                                 :scenario => stub(:steps => []))

      Turnip::StepDefinition.should_receive(:execute).exactly(3).times
      runner.run
    end

    it 'iterates over the scenario steps' do
      runner.context = stub(:backgrounds => [],
                                 :available_background_steps => [],
                                 :available_scenario_steps => [],
                                 :scenario => stub(:steps => (0..3)))

      Turnip::StepDefinition.should_receive(:execute).exactly(4).times
      runner.run
    end
  end

  describe '#run_steps' do
    let(:available_steps) { stub }

    it 'executes the steps with the current world' do
      step = stub
      steps = [step]
      runner.available_steps = available_steps

      Turnip::StepDefinition.should_receive(:execute).with(world, available_steps, step)
      runner.run_steps(steps)
    end

    it 'iterates over the steps' do
      steps = (0..2)

      Turnip::StepDefinition.should_receive(:execute).exactly(3).times
      runner.run_steps(steps)
    end
  end
end
