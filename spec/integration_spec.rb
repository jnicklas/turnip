require 'spec_helper'

describe 'The CLI', :type => :integration do
  before do
    @result = %x(rspec -fd examples/*.feature)
  end

  it "shows the correct description" do
    @result.should include('A simple feature')
    @result.should include('This is a simple feature')
    @result.should include('Given there is a monster -> When I attack it -> Then it should die')
  end

  it "prints out failures and successes" do
    @result.should include('39 examples, 4 failures, 5 pending')
  end

  it "includes features in backtraces" do
    @result.should include('examples/errors.feature:5:in `raise error')
    @result.should include('examples/errors.feature:11:in `a step just does not exist')
  end

  it "includes the right step name when steps call steps" do
    @result.should include("No such step: 'this is an unimplemented step'")
  end

  it 'prints line numbers of pending/failure scenario' do
    @result.should include('./examples/pending.feature:3')
    @result.should include('./examples/errors.feature:4')
    @result.should include('./examples/errors.feature:6')
    @result.should include('./examples/errors.feature:11')
  end

  it 'conforms to line-number option' do
    @result.should include('rspec ./examples/errors.feature:4')
    @result.should include('rspec ./examples/errors.feature:6')
    @result.should include('rspec ./examples/errors.feature:11')
    result_with_line_number = %x(rspec -fd ./examples/errors.feature:4)
    result_with_line_number.should include('rspec ./examples/errors.feature:4')
    result_with_line_number.should_not include('rspec ./examples/errors.feature:6')
    result_with_line_number.should_not include('rspec ./examples/errors.feature:11')
  end
end
