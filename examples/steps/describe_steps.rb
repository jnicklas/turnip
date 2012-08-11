steps_for :describe_feature do
	step "foo" do
		puts example.class.ancestors
		example.metadata[:type].should == :controller
	end
end