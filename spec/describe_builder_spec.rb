require 'spec_helper'

describe Turnip::Builder do
  context "with describe tags" do
    let(:feature_file) { File.expand_path('../examples/describe.feature', File.dirname(__FILE__)) }
    let(:builder) { Turnip::Builder.build(feature_file) }

    it "should return Class args for descibe if set" do
      builder.describe_class.should == String
    end

    it "should return options hash for describe if set" do
      builder.describe_options.should == {:type => :controller}
    end
  end

end
