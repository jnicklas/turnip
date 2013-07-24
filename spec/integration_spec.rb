require 'spec_helper'

describe 'The CLI', :type => :integration do
  before do
    @result = %x(rspec -fs examples/*.feature)
  end

  it "shows the correct description" do
    @result.should include('A simple feature')
    @result.should include('is a simple feature')
  end

  it "prints out failures and successes" do
    @result.should include('35 examples, 3 failures, 5 pending')
  end

  it "includes features in backtraces" do
    @result.should include('examples/errors.feature:5:in `raise error')
  end

  it "includes the right step name when steps call steps" do
    @result.should include("No such step: 'this is an unimplemented step'")
  end
end
