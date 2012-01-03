module Turnip
  class ScenarioContext
    attr_accessor :feature
    attr_accessor :scenario

    def initialize(feature, scenario)
      self.feature = feature
      self.scenario = scenario
    end

    def available_background_steps
      available_steps_for(*feature_tags)
    end

    def available_scenario_steps
      available_steps_for(*scenario_tags)
    end

    def backgrounds
      feature.backgrounds
    end

    def modules
      Turnip::StepModule.modules_for(*scenario_tags)
    end

    private

    def available_steps_for(*tags)
      Turnip::StepModule.all_steps_for(*tags)
    end

    def feature_tags
      @feature_tags ||= feature.active_tags.uniq
    end

    def scenario_tags
      @scenario_tags ||= (feature_tags + scenario.active_tags).uniq
    end
  end
end
