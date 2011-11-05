module Turnip
  module DSL
    class << self
      attr_accessor :current_taggings
    end

    def step(description, options={}, &block)
      if Turnip::DSL.current_taggings
        options[:for] = [options[:for], *Turnip::DSL.current_taggings].compact.flatten
      end
      Turnip::StepDefinition.add(description, options, &block)
    end

    def steps_for(*taggings)
      Turnip::DSL.current_taggings = [taggings, *Turnip::DSL.current_taggings].compact.flatten
      yield
      Turnip::DSL.current_taggings = nil
    end

    def placeholder(name, &block)
      Turnip::Placeholder.add(name, &block)
    end
  end
end
