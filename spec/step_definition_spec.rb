describe Turnip::StepDefinition do
  describe "#match" do
    it "matches alternative words" do
      step = Turnip::StepDefinition.new("there is/are monsters") {}
      step.should match("there are monsters")
      step.should match("there is monsters")
      step.should_not match("there be monsters")
    end

    it "matches several alternative words" do
      step = Turnip::StepDefinition.new("monsters are cool/nice/scary") {}
      step.should match("monsters are cool")
      step.should match("monsters are nice")
      step.should match("monsters are scary")
      step.should_not match("monsters are sexy")
    end

    it "matches optional parts of words" do
      step = Turnip::StepDefinition.new("there is/are X monster(s)") {}
      step.should match("there is X monster")
      step.should_not match("there is X monsterQ")
    end

    it "matches optional words" do
      step = Turnip::StepDefinition.new("there is a (scary) monster") {}
      step.should match("there is a monster")
      step.should match("there is a scary monster")
      step.should_not match("there is a terrifying monster")

      step = Turnip::StepDefinition.new("there is a monster (that is scary)") {}
      step.should match("there is a monster that is scary")
      step.should match("there is a monster")

      step = Turnip::StepDefinition.new("(there is) a monster") {}
      step.should match("there is a monster")
      step.should match("a monster")
    end
  end
end

