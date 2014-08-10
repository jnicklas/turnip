require "spec_helper"

describe Turnip::Execute do
  let(:mod) { Module.new }
  let(:obj) { Object.new.tap { |o| o.extend Turnip::Execute; o.extend mod } }

  it "defines a step method and makes it callable" do
    mod.step("a test step") { "monkey" }
    obj.step("a test step").should == "monkey"
  end

  it "allows placeholders to be filled and passed as arguments" do
    mod.step("a :test step") { |test| test.upcase }
    obj.step("a cool step").should == "COOL"
  end

  it "allows step to be called as a method via `send`" do
    mod.step("a :test step") { |test| test.upcase }
    obj.send("a :test step", "cool").should == "COOL"
  end

  it "can use an existing method as a step" do
    mod.module_eval do
      def a_test_step(test)
        test.upcase
      end
    end
    mod.step(:a_test_step, "a :test step")
    obj.step("a cool step").should == "COOL"
  end

  it "raises an argument error when both method name and block given" do
    expect do
      mod.step(:a_test_step, "a :test step") { "foo" }
    end.to raise_error(ArgumentError)
  end

  it "sends in extra arg from a builder step" do
    mod.step("a :test step") { |test, foo| test.upcase + foo }
    obj.step("a cool step", "foo").should == "COOLfoo"
  end

  it "can be executed with a builder step" do
    builder_step = double(:description => "a cool step", :extra_args => [])
    mod.step("a :test step") { |test| test.upcase }
    obj.step(builder_step).should == "COOL"
  end

  it "sends in extra arg from a builder step" do
    builder_step = double(:description => "a cool step", :extra_args => ["foo"])
    mod.step("a :test step") { |test, foo| test.upcase + foo }
    obj.step(builder_step).should == "COOLfoo"
  end

  it "defines ambiguous steps and run a matching step" do
    mod.step("an ambiguous step") {}
    mod.step("an :ambiguous step") {}
    expect {
      obj.step("an ambiguous step")
    }.to raise_error(Turnip::Ambiguous)
  end

  it "shows useful information on the ambiguous steps" do
    mod.step("an ambiguous step") {}
    mod.step("an :ambiguous step") {}
    expect {
      obj.step("an ambiguous step")
    }.to raise_error(Turnip::Ambiguous, %r{(ambiguous).*(define_and_execute_spec.rb)})
  end
end
