module Turnip
  class ScenarioContext
    attr_accessor :world

    def initialize(world)
      self.world = world
    end

    def enable_tags(*tags)
      available_tags.concat(tags).uniq!
      load_modules(*tags)
    end

    def available_steps
      Turnip::StepModule.all_steps_for(*available_tags)
    end

    def available_tags
      @tags ||= []
    end

    private

    def load_modules(*tags)
      modules = Turnip::StepModule.modules_for(*tags)
      modules.each { |mod| world.extend mod }
    end

  end
end
