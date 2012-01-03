module Turnip
  class ScenarioRunner
    attr_accessor :available_steps
    attr_accessor :context
    attr_accessor :world

    def initialize(world)
      self.world = world
    end

    def load(context)
      self.context = context
      world.extend Turnip::RunnerDSL
      world.turnip_runner = self
      context.modules.each {|mod| world.extend mod }
      self
    end

    def run
      self.available_steps = context.available_background_steps
      context.backgrounds.each do |background|
        run_steps(background.steps)
      end

      self.available_steps = context.available_scenario_steps
      run_steps(context.scenario.steps)
    end

    def run_steps(steps)
      steps.each do |step|
        Turnip::StepDefinition.execute(world, available_steps, step)
      end
    end
  end
end
