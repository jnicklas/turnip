require 'turnip/step_loader'

describe Turnip::StepLoader do
  describe '.load_steps' do
    context 'when the steps have not been loaded' do
      before { Turnip::StepLoader.steps_loaded = false }

      it 'loads all the steps' do
        Turnip::StepLoader.should_receive :load_step_files
        Turnip::StepLoader.load_steps
      end

      it 'marks the steps as loaded' do
        Turnip::StepLoader.stub :load_step_files
        Turnip::StepLoader.load_steps
        Turnip::StepLoader.should be_steps_loaded
      end
    end

    context 'when the steps have been loaded' do
      before { Turnip::StepLoader.steps_loaded = true }

      it 'does not reload all the steps' do
        Turnip::StepLoader.should_not_receive :load_step_files
        Turnip::StepLoader.load_steps
      end
    end
  end
end
