require "spec_helper"

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

    it "extracts arguments from matched steps" do
      step = Turnip::StepDefinition.new("a :age year old monster called :name") {}
      match = step.match("a 3 year old monster called John")
      match.params.should eq(["3", "John"])
    end

    it "can reuse the same placeholder multiple times" do
      step = Turnip::StepDefinition.new("a the monsters :name and :name") {}
      match = step.match("a the monsters John and Trudy")
      match.params.should eq(["John", "Trudy"])
    end

    it "can reuse the same custom placeholder multiple times" do
      Turnip::Placeholder.stub(:resolve).with(:count).and_return(/\d+/)
      Turnip::Placeholder.stub(:apply).with(:count, "3").and_return(3)
      Turnip::Placeholder.stub(:apply).with(:count, "2").and_return(2)
      step = Turnip::StepDefinition.new(":count monsters and :count knights") {}
      match = step.match("3 monsters and 2 knights")
      match.params.should eq([3, 2])
    end

    it "does search for the same custom placeholder several times" do
      placeholder = Turnip::Placeholder.add(:count) { match(/\d/) { |count| count.to_i } }
      Turnip::Placeholder.stub(:resolve).with(:count).and_return(/\d+/)
      Turnip::Placeholder.should_receive(:find).with(:count).twice.and_return(placeholder)
      step = Turnip::StepDefinition.new(":count monsters and :count knights") {}
      match = step.match("3 monsters and 2 knights")
      #match.params.should eq([3, 2])
    end

    it "does apply the same custom placeholder several times" do
      placeholder = Turnip::Placeholder.add(:count) { match(/\d/) { |count| count.to_i } }
      Turnip::Placeholder.stub(:resolve).with(:count).and_return(/\d+/)
      placeholder.should_receive(:apply).twice
      step = Turnip::StepDefinition.new(":count monsters and :count knights") {}
      match = step.match("3 monsters and 2 knights")
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
