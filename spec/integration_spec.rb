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
    @result.should include('24 examples, 1 failure, 2 pending')
  end
end
