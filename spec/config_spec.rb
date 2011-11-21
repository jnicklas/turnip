require 'turnip/config'

module Turnip::StepModule; end

describe Turnip::Config do
  describe '.load_steps' do
    context 'when the steps have not been loaded' do
      before { Turnip::Config.steps_loaded = false }

      it 'loads all the steps' do
        Turnip::StepModule.should_receive :load_steps
        Turnip::Config.load_steps
      end

      it 'marks the steps as loaded' do
        Turnip::StepModule.stub :load_steps
        Turnip::Config.load_steps
        Turnip::Config.should be_steps_loaded
      end
    end

    context 'when the steps have been loaded' do
      before { Turnip::Config.steps_loaded = true }

      it 'does not reload all the steps' do
        Turnip::StepModule.should_not_receive :load_steps
        Turnip::Config.load_steps
      end
    end
  end
end
