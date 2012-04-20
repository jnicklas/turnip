module Turnip
  module Config
    extend self

    def step_dirs
      @step_dirs ||= ['spec']
    end

    def step_dirs=(dirs)
      @step_dirs = [] unless @step_dirs
      @step_dirs.concat(Array(dirs))
    end
  end
end
