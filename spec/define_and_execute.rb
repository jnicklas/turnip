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

  it "sends in extra arg from a builder step" do
    mod.step("a :test step") { |test, foo| test.upcase + foo }
    obj.step("a cool step", "foo").should == "COOLfoo"
  end

  it "can be executed with a builder step" do
    builder_step = stub(:to_s => "a cool step", :extra_args => [])
    mod.step("a :test step") { |test| test.upcase }
    obj.step(builder_step).should == "COOL"
  end

  it "sends in extra arg from a builder step" do
    builder_step = stub(:to_s => "a cool step", :extra_args => ["foo"])
    mod.step("a :test step") { |test, foo| test.upcase + foo }
    obj.step(builder_step).should == "COOLfoo"
  end
end
