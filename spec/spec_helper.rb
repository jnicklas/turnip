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
