steps_for :global do
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

  step "there are :count monkeys with :color hair" do |count, color|
    @monkeys = Array.new(count) { color }
  end

  step "there should be 3 monkeys with blue hair" do
    @monkeys.should == [:blue, :blue, :blue]
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

  step "that alignment should be :alignment" do |alignment|
    @alignment.should eq(alignment)
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
end
