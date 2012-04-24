module Turnip
  module StepLoader
    extend self

    attr_accessor :steps_loaded

    def load_steps
      return if steps_loaded?
      load_step_files
      self.steps_loaded = true
    end

    def steps_loaded?
      @steps_loaded
    end

    private

    def load_step_files
      Turnip.step_dirs.each do |dir|
        Pathname.glob(Pathname.new(dir) + '**' + "*steps.rb").each do |step_file|
          load step_file, true
        end
      end
    end
  end
end
