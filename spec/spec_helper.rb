RSpec.configure do |config|
  Turnip::Config.step_dirs = 'examples'
  Turnip::StepModule.load_steps

  config.before(:each, :turnip => true) do
  end
end
