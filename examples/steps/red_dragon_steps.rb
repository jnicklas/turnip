require_relative "knight_steps"

steps_for :red_dragon do
  use_steps :dragon

  attr_accessor :red_dragon

  def dragon_attack
    attack = super
    if red_dragon
      attack + 15
    else
      attack
    end
  end

  step "the dragon breathes fire" do
    self.red_dragon = 1
  end
end
