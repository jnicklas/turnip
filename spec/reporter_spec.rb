require "spec_helper"

describe Turnip::RSpec::Execute do
  let(:mod) { Module.new }
  let(:obj) { Object.new.tap { |o| o.extend Turnip::RSpec::Execute; o.extend mod; def o.skip(*args); end } }
  let(:reporter) { RSpec.current_example.reporter }

  before { allow(reporter).to receive(:publish).and_call_original }

  def create_step_node(text)
    Turnip::Node::Step.new(location: { line: 1, column: 0 }, text: text)
  end

  context '#run_step' do
    it "publishes :step_started event when step is starting" do
      step = create_step_node "a test step"

      obj.run_step 'test.feature', step

      expect(reporter).to have_received(:publish).with(:step_started, step: step)
    end

    it "publishes :step_passed event when step has passed" do
      mod.step("a test step") { true }
      step = create_step_node "a test step"

      obj.run_step 'test.feature', step

      expect(reporter).to have_received(:publish).with(:step_passed, step: step)
    end

    it "publishes :step_failed event when step has failed" do
      mod.step("a failing step") { raise ::RSpec::Expectations::ExpectationNotMetError }
      step = create_step_node "a failing step"

      begin
        obj.run_step 'test.feature', step
      rescue ::RSpec::Expectations::ExpectationNotMetError => e
      end

      expect(reporter).to have_received(:publish).with(:step_failed, step: step)
    end

    it "publishes :step_pending event when step is pending" do
      step = create_step_node "a pending step"

      obj.run_step 'test.feature', step

      expect(reporter).to have_received(:publish).with(:step_pending, step: step)
    end
  end
end
