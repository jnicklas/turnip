require 'spec_helper'

describe 'The CLI', :type => :integration do
  describe 'rspec -fs examples/simple_feature.feature' do
    it "shows the correct description" do
      result.should include('A simple feature')
      result.should include('is a simple feature')
    end

    it "passes" do
      result.should include('1 example, 0 failures')
    end
  end

  describe 'rspec -fs examples/ambiguous.feature' do
    it "fails" do
      result.should include('1 example, 1 failure')
    end
  end

  describe 'rspec -fs examples/backgrounds.feature' do
    it "passes" do
      result.should include('1 example, 0 failures')
    end
  end

  describe 'rspec -fs examples/interpolation.feature' do
    it "passes" do
      result.should include('3 examples, 0 failures')
    end
  end

  describe 'rspec -fs examples/pending.feature' do
    it "is marked as pending" do
      result.should include('1 example, 0 failures, 1 pending')
    end
  end

  describe 'rspec -fs examples/tags.feature' do
    it "passes" do
      result.should include('2 examples, 0 failures')
    end
  end
end
