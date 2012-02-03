module Turnip
  class ScenarioRunner
    attr_accessor :context
    attr_accessor :world

    def initialize(world)
      self.world = world
      self.context = Turnip::ScenarioContext.new(world)
      world.extend Turnip::RunnerDSL
      world.turnip_runner = self
      world.turnip_context = self.context
    end

    def run(feature, scenario)
      run_background_steps(feature)
      run_scenario_steps(scenario)
    end

    def run_background_steps(feature)
      context.enable_tags(*feature.active_tags)
      feature.backgrounds.each do |background|
        run_steps(background.steps)
      end
    end

    def run_scenario_steps(scenario)
      context.enable_tags(*scenario.active_tags)
      run_steps(scenario.steps)
    end

    def run_steps(steps)
      steps.each do |step|
        Turnip::StepDefinition.execute(world, context.available_steps, step)
      end
    end

  end
end
