module Turnip
  module RunnerDSL
    attr_accessor :turnip_runner
    attr_accessor :turnip_context

    def step(description, extra_arg = nil)
      turnip_runner.run_steps([Turnip::Builder::Step.new(description, extra_arg)])
    end

    def enable_steps_for(tag)
      turnip_context.enable_tags(tag.to_sym)
    end

    def disable_steps_for(tag)
      turnip_context.disable_tags(tag.to_sym)
    end

  end
end
