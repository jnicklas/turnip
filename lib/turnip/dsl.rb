module Turnip
  module DSL
    def placeholder(name, &block)
      Turnip::Placeholder.add(name, &block)
    end

    def step(description, &block)
      Turnip::Steps.step(description, &block)
    end

    def steps_for(tag, &block)
      if tag.to_s == "global"
        warn "[Turnip] using steps_for(:global) is deprecated, add steps to Turnip::Steps instead"
        Turnip::Steps.module_eval(&block)
      else
        Module.new do
          singleton_class.send(:define_method, :tag) { tag }

          [:before, :after, :around].each do |hook|
            singleton_class.send(:define_method, hook) do |scope, options = {}, &block|
              ::RSpec.configure do |config|
                config.send(hook, scope, { tag => true }.merge(options), &block)
              end
            end
          end


          module_eval(&block)
          ::RSpec.configure { |c| c.include self, tag => true }
        end
      end
    end
  end
end
