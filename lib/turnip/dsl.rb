module Turnip
  module DSL
    def placeholder(name, &block)
      Turnip::Placeholder.add(name, &block)
    end

    def step(description, &block)
      global_step_module_entry.step_module.steps << Turnip::StepDefinition.new(description, &block)
    end

    def steps_for(*taggings, &block)
      Turnip::StepModule.steps_for(*taggings, &block)
    end

    private

    def global_step_module_entry
      @global_step_module_entry ||= begin
                                      anon = Module.new do
                                        def self.steps
                                          @steps ||= []
                                        end
                                      end
                                      entry = Turnip::StepModule::Entry.new([:global], anon, [])
                                      Turnip::StepModule.module_registry[:global] << entry
                                      entry
                                    end
    end
  end
end
