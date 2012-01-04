module Turnip
  module RunnerDSL
    attr_accessor :turnip_runner

    def step(description, extra_arg = nil)
      turnip_runner.run_steps([Turnip::Builder::Step.new(description, extra_arg)])
    end
  end
end
