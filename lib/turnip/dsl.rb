module Turnip
  module DSL
    def steps_for(*taggings, &block)
      Turnip::StepModule.steps_for(*taggings, &block)
    end
  end
end
