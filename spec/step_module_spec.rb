describe Turnip::StepModule do
  before(:each) do
    Turnip::StepModule.clear_module_registry
  end

  describe '.modules_for' do
    it 'returns the unique registered modules' do
      Turnip::StepModule.steps_for(:first) {}
      Turnip::StepModule.steps_for(:first, :second) {}
      Turnip::StepModule.modules_for(:first, :second).size.should eq(2)
    end

    it 'returns the unique registered modules with use_steps' do
      Turnip::StepModule.steps_for(:first) {}
      Turnip::StepModule.steps_for(:second) { use_steps :first }
      Turnip::StepModule.steps_for(:third) { use_steps :first, :second }
      Turnip::StepModule.modules_for(:third).size.should eq(3)
    end

    it 'ignores a circular step dependency' do
      Turnip::StepModule.steps_for(:first) { use_steps :second }
      Turnip::StepModule.steps_for(:second) { use_steps :first }
      expect do
        Turnip::StepModule.modules_for(:second)
      end.should_not raise_error
    end
  end

  describe '.steps_for' do
    it 'registers for the given tags' do
      Turnip::StepModule.steps_for(:first, :second) {}
      Turnip::StepModule.should be_registered(:first)
      Turnip::StepModule.should be_registered(:second)
    end

    it 'registers an anonymous modle for the given tags' do
      Turnip::StepModule.steps_for(:first) {}
      Turnip::StepModule.module_registry[:first].first.step_module.should be_instance_of(Module)
    end

    it 'registers the same module for multiple tags' do
      Turnip::StepModule.steps_for(:first, :second) {}
      Turnip::StepModule.module_registry[:first].first.should eq(Turnip::StepModule.module_registry[:second].first)
    end
  end

  describe '.step_module' do
    subject do
      Turnip::StepModule.step_module do
        def marker; end
      end
    end

    it 'creates an anonymous module' do
      subject.name.should be_nil
    end

    it 'extends the steps DSL' do
      subject.should be_kind_of(Turnip::StepModule::DSL)
    end

    it 'executes the block in the module' do
      subject
      subject.instance_methods.should include(:marker)
    end
  end

  describe Turnip::StepModule::DSL do
    describe '.step' do
      it 'registers the step for the module' do
        mod = Module.new do
          extend Turnip::StepModule::DSL
          step('example') { true }
        end
        mod.steps.first.expression.should eq('example')
      end
    end

    describe '.placeholder' do
      before { Turnip::Placeholder.send(:placeholders).clear }

      it 'registers the placeholder globally' do
        mod = Module.new do
          extend Turnip::StepModule::DSL
          placeholder('example') { true }
        end
        Turnip::Placeholder.send(:placeholders).should have_key('example')
      end
    end

    describe '.use_steps' do
      it "updates the list of used steps" do
        mod = Module.new do
          extend Turnip::StepModule::DSL
          step('example') { true }

          use_steps :other_steps
        end
        mod.uses_steps.should include(:other_steps)
      end
    end
  end
end
