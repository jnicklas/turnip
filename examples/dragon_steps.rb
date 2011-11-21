steps_for :dragon do
  use_steps :knight

  attr_accessor :dragon

  def dragon_attack
    dragon * 10
  end

  step "there is a dragon" do
    self.dragon = 1
  end

  step "the dragon attacks the knight" do
    knight.attacked_for(dragon_attack)
  end
end
