module Turnip
  module Config
    extend self

    attr_accessor :autotag_features

    def step_dirs
      @step_dirs ||= ['spec']
    end

    def step_dirs=(dirs)
      @step_dirs = [] unless @step_dirs
      @step_dirs.concat(Array(dirs))
    end
  end
end

Turnip::Config.autotag_features = true
