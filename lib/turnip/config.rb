module Turnip
  module Config
    extend self

    attr_accessor :autotag_features
    attr_accessor :steps_loaded

    def load_steps
      return if steps_loaded?
      Turnip::StepModule.load_steps
      self.steps_loaded = true
    end

    def step_dirs
      @step_dirs ||= ['spec']
    end

    def step_dirs=(dirs)
      @step_dirs = [] unless @step_dirs
      @step_dirs.concat(Array(dirs))
    end

    def steps_loaded?
      @steps_loaded
    end
  end
end

Turnip::Config.autotag_features = true
