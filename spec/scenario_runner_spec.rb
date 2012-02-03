require 'spec_helper'

describe Turnip::ScenarioRunner do
  let(:runner) { Turnip::ScenarioRunner.new(world) }
  let(:world) { Object.new }

  describe '#initialize' do
    it 'keeps track of the world' do
      runner.world.should eq(world)
    end

    it 'loads the DSL module into the world' do
      runner.world.should be_kind_of(Turnip::RunnerDSL)
    end

    it 'adds the runner to the world' do
      runner.world.turnip_runner.should eq(runner)
    end

    it 'creates a scenario context' do
      runner.context.should be_kind_of(Turnip::ScenarioContext)
    end
  end

  describe '#run' do
    it 'runs steps' do
      feature = stub
      scenario = stub
      runner.should_receive(:run_background_steps).with(feature)
      runner.should_receive(:run_scenario_steps).with(scenario)
      runner.run(feature, scenario)
    end
  end

  describe '#run_background_steps' do
    it 'iterates over the background steps' do
      feature = stub(:backgrounds => (0..2).map { stub(:steps => [stub]) },
                     :active_tags => [])

      Turnip::StepDefinition.should_receive(:execute).exactly(3).times
      runner.run_background_steps(feature)
    end

    it 'enables feature tags' do
      feature_tags = [stub]
      feature = stub(:backgrounds => [],
                     :active_tags => feature_tags)
      runner.context = stub
      runner.context.should_receive(:enable_tags).with(*feature_tags)
      runner.run_background_steps(feature)
    end
  end

  describe '#run_scenario_steps' do
    it 'iterates over the scenario steps' do
      scenario = stub(:active_tags => [],
                      :steps => (0..3))

      Turnip::StepDefinition.should_receive(:execute).exactly(4).times
      runner.run_scenario_steps(scenario)
    end

    it 'enables scenario tags' do
      scenario_tags = [stub]
      scenario = stub(:steps => [],
                     :active_tags => scenario_tags)
      runner.context = stub
      runner.context.should_receive(:enable_tags).with(*scenario_tags)
      runner.run_scenario_steps(scenario)
    end
  end

  describe '#run_steps' do
    let(:available_steps) { stub }

    it 'executes the steps with the current world' do
      step = stub
      steps = [step]
      runner.context = stub(:available_steps => available_steps)

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
