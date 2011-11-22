module Turnip
  module Loader
    def load(*a, &b)
      if a.first.end_with?('.feature')
        require 'spec_helper'
        Turnip::StepLoader.load_steps
        Turnip.run(Turnip::FeatureFile.new(a.first))
      else
        super
      end
    end
  end
end
