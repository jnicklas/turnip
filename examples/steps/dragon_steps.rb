require_relative "knight_steps"

module DragonSteps
  include KnightSteps

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

module RedDragonSteps
  include DragonSteps

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

RSpec.configure { |c| c.include DragonSteps, :dragon => true }
RSpec.configure { |c| c.include RedDragonSteps, :red_dragon => true }
