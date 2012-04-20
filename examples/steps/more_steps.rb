step "there are :count monkeys with :color hair" do |count, color|
  @monkeys = Array.new(count) { color }
end

step "there should be 3 monkeys with blue hair" do
  @monkeys.should == [:blue, :blue, :blue]
end
