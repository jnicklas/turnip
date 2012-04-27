describe Turnip::StepDefinition do
  let(:all_steps) { [] }

  describe "#match" do
    it "matches a simple step" do
      step = Turnip::StepDefinition.new("there are monsters") {}
      step.should match("there are monsters")
      step.should_not match("there are monsters around")
      step.should_not match("there are people")
    end

    it "matches placeholders" do
      Turnip::Placeholder.stub(:resolve).with(:count).and_return(/\d+/)
      step = Turnip::StepDefinition.new("there are :count monsters") {}
      step.should match("there are 4 monsters")
      step.should match("there are 324 monsters")
      step.should_not match("there are no monsters")
    end

    it "matches quoted placeholders" do
      step = Turnip::StepDefinition.new("there is a monster named :name") {}
      step.should match("there is a monster named 'Scary'")
      step.should match('there is a monster named "Hairy"')
    end

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
