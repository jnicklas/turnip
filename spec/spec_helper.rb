step "there is a monster" do
  @monster = 1
end

step "there is a strong monster" do
  @monster = 2
end

step "I attack it" do
  @monster -= 1
end

step "it should die" do
  @monster.should eq(0)
end

step "this is ambiguous" do
end

step "this is ambiguous" do
end

step "there is a monster called :name" do |name|
  @monster_name = name
end

step 'it should be called "John Smith"' do
  @monster_name.should == "John Smith"
end

step 'it should be called "John"' do
  @monster_name.should == "John"
end
