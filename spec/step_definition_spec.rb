describe Turnip::StepDefinition do
  after do
    Turnip::StepDefinition.all.clear
  end

  describe ".add" do
    it "adds a step definition to the list of definitions" do
      Turnip::StepDefinition.add "this is a test"
      Turnip::StepDefinition.all.first.expression.should eq("this is a test")
    end
  end

  describe ".find" do
    it "returns a step definition that matches the description" do
      Turnip::StepDefinition.add "there are :count monsters"
      Turnip::StepDefinition.find("there are 23 monsters").expression.should eq("there are :count monsters")
    end

    it "respects the for option" do
      Turnip::StepDefinition.add "alignment", :for => [:evil]
      Turnip::StepDefinition.add "alignment", :for => [:good]
      Turnip::StepDefinition.find("alignment", :evil => true, :bad => true).options[:for].should == [:evil]
    end

    it "raises an error if the match is ambiguous" do
      Turnip::StepDefinition.add "there are :count monsters"
      Turnip::StepDefinition.add "there are 23 monsters"
      expect { Turnip::StepDefinition.find("there are 23 monsters") }.to raise_error(Turnip::StepDefinition::Ambiguous)
    end

    it "raises an error if there is no match" do
      expect { Turnip::StepDefinition.find("there are 23 monsters") }.to raise_error(Turnip::StepDefinition::Pending)
    end
  end

  describe ".execute" do
    it "executes a step in the given context" do
      context = stub(:example => stub(:metadata => {}))
      Turnip::StepDefinition.add("there are :count monsters") { @testing = 123 }
      Turnip::StepDefinition.execute(context, stub(:description => "there are 23 monsters", :extra_arg => nil))
      context.instance_variable_get(:@testing).should == 123
    end

    it "tells the context that the step is pending" do
      context = stub(:example => stub(:metadata => {}))
      context.should_receive(:pending).with("the step 'there are 23 monsters' is not implemented")
      Turnip::StepDefinition.execute(context, stub(:description => "there are 23 monsters", :extra_arg => nil))
    end

    it "sends along arguments" do
      context = stub(:example => stub(:metadata => {}))
      Turnip::StepDefinition.add("there are :count monsters") { |count| @testing = count.to_i }
      Turnip::StepDefinition.execute(context, stub(:description => "there are 23 monsters", :extra_arg => nil))
      context.instance_variable_get(:@testing).should == 23
    end

    it "sends along extra arguments" do
      context = stub(:example => stub(:metadata => {}))
      Turnip::StepDefinition.add("there are :count monsters") { |count, extra| @testing = extra }
      Turnip::StepDefinition.execute(context, stub(:description => "there are 23 monsters", :extra_arg => 'foo'))
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

