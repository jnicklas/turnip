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
    @result.should include('27 examples, 2 failures, 2 pending')
  end
  
  it "prints out the file name and line number" do
    @result.should include("./examples/failing.feature:4")
  end
end