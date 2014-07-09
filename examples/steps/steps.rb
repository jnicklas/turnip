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

step "this is :ambiguous" do
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

step 'it should be called "O\'Flannahan"' do
  @monster_name.should == "O'Flannahan"
end

step "I change its name to :empty_string" do |empty_string|
  @monster_name = empty_string
end

step "it should be nameless" do
  @monster_name.should == ""
end

step "the monster introduced himself:" do |self_introduction|
  self_introduction.should include @monster_name
end

step "there is a monster with :count hitpoints" do |count|
  @monster = count
end

step "I attack the monster and do :count points damage" do |count|
  @monster -= count
end

step "the monster should be alive" do
  @monster.should > 0
end

step "the monster should be dead" do
  @monster.should <= 0
end

step "there are the following monsters:" do |table|
  @monsters = {}
  table.hashes.each do |hash|
    @monsters[hash['Name']] = hash['Hitpoints'].to_i
  end
end

step ":name should have :count hitpoints" do |name, count|
  @monsters[name].should eq(count.to_i)
end

step "the monster sings the following song" do |song|
  @song = song
end

step "the song should have :count lines" do |count|
  @song.to_s.split("\n").length.should eq(count)
end

step "it should be strong/tough" do
  @monster.should >= 2
end

step "it should be (a) badass" do
  @monster.should >= 2
end

step "it should be (a) badass" do
  @monster.should >= 2
end

step "it should be terrible(st)" do
  @monster.should >= 2
end

step "it (should) have/has :count (terrifying) hitpoint(s)" do |count|
  @monster.should == count
end

step "raise error" do
  raise "foobar"
end

placeholder :count do
  match /\d+/ do |count|
    count.to_i
  end
end

placeholder :color do
  match /blue|green|red/ do |color|
    color.to_sym
  end
end
