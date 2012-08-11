steps_for :describe_feature do
	step "foo" do
		described_class.should == String
		example.metadata[:type].should == :controller
	end

	step "bar" do
	end

	step "baz" do
	end
end