module Turnip
  module DSL
    def step(description, &block)
      Turnip::Steps.add_step(description, &block)
    end
  end
end

self.extend Turnip::DSL

