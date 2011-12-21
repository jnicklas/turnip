describe Turnip::StepDefinition do
  let(:all_steps) { [] }

  describe ".find" do
    it "returns a step definition that matches the description" do
      all_steps << Turnip::StepDefinition.new("there are :count monsters")
      Turnip::StepDefinition.find(all_steps, "there are 23 monsters").expression.should eq("there are :count monsters")
    end

    it "raises an error if the match is ambiguous" do
      all_steps << Turnip::StepDefinition.new("there are :count monsters")
      all_steps << Turnip::StepDefinition.new("there are 23 monsters")
      expect { Turnip::StepDefinition.find(all_steps, "there are 23 monsters") }.to raise_error(Turnip::StepDefinition::Ambiguous)
    end

    it "raises an error if there is no match" do
      expect { Turnip::StepDefinition.find(all_steps, "there are 23 monsters") }.to raise_error(Turnip::StepDefinition::Pending)
    end
  end

  describe ".execute" do
    let(:context) { stub }

    it "executes a step in the given context" do
      all_steps << Turnip::StepDefinition.new("there are :count monsters") { @testing = 123 }
      Turnip::StepDefinition.available_steps = all_steps
      Turnip::StepDefinition.execute(context, stub(:description => "there are 23 monsters", :extra_arg => nil, :active_tags => [:global]))
      context.instance_variable_get(:@testing).should == 123
    end

    it "tells the context that the step is pending" do
      Turnip::StepDefinition.available_steps = []
      context.should_receive(:pending).with("the step 'there are 23 monsters' is not implemented")
      Turnip::StepDefinition.execute(context, stub(:description => "there are 23 monsters", :extra_arg => nil, :active_tags => [:global]))
    end

    it "sends along arguments" do
      all_steps << Turnip::StepDefinition.new("there are :count monsters") { |count| @testing = count.to_i }
      Turnip::StepDefinition.available_steps = all_steps
      Turnip::StepDefinition.execute(context, stub(:description => "there are 23 monsters", :extra_arg => nil, :active_tags => [:global]))
      context.instance_variable_get(:@testing).should == 23
    end

    it "sends along extra arguments" do
      all_steps << Turnip::StepDefinition.new("there are :count monsters") { |count, extra| @testing = extra }
      Turnip::StepDefinition.available_steps = all_steps
      Turnip::StepDefinition.execute(context, stub(:description => "there are 23 monsters", :extra_arg => 'foo', :active_tags => [:global]))
      context.instance_variable_get(:@testing).should == 'foo'
    end
  end

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
