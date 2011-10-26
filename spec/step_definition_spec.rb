describe Turnip::StepDefinition do
  describe "#match" do
    it "matches alternative words" do
      step = Turnip::StepDefinition.new("there is/are monsters") {}
      step.match("there are monsters").should_not be_nil
      step.match("there is monsters").should_not be_nil
    end
    
    it "matches optional parts of words" do
      step = Turnip::StepDefinition.new("there is/are X monster(s)") {}
      step.match("there is X monster").should_not be_nil
    end
  end
end