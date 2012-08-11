require 'spec_helper'

describe Turnip::Builder do
  context "describe.feature" do
    let(:feature_file) { File.expand_path('../examples/describe.feature', File.dirname(__FILE__)) }

    context "with describe tags" do
      let(:builder) { Turnip::Builder.build(feature_file) }

      it "should return Class args for descibe if set" do
        builder.describe_class.should == String
      end

      it "should return options hash for describe if set" do
        builder.describe_options.should == {:type => :controller}
      end
    end

    describe 'run rspec and check if a class is set', :type => :integration do
      before do
        @result = %x(rspec -fs examples/describe.feature)
      end

      it "succeeds to run" do
        @result.should include('34 examples, 3 failures, 4 pending')
      end
    end
  end
end
