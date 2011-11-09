steps_for :red_dragon do
  use_steps :dragon

  attr_accessor :red_dragon

  def dragon_attack
    30
    attack = super
    if red_dragon
      attack + 10
    else
      attack
    end
  end

  step "it is a fire breathing red dragon" do
    self.red_dragon = 1
  end
end

