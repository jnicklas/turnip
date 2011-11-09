steps_for :dragon do
  attr_accessor :dragon

  def dragon_attack
    dragon * 10
  end

  step "there is a dragon" do
    self.dragon = 1
  end

  step "the dragon attacks for :count hitpoints" do |count|
    dragon_attack.should eq(count)
  end
end
