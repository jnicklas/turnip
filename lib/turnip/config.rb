module Turnip
  module Config
    extend self
    
    attr_accessor :autotag_features, :step_match_mode
    
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
Turnip::Config.step_match_mode = :flexible # or :exact or :generic