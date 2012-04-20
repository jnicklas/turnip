module Turnip
  module Loader
    def load(*a, &b)
      if a.first.end_with?('.feature')
        begin
          require 'spec_helper'
        rescue LoadError
        end
        Turnip::StepLoader.load_steps
        Turnip.run(a.first)
      else
        super
      end
    end
  end
end
