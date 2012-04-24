module KnightSteps
  attr_accessor :knight

  class Knight
    def initialize
      @hp = 20
    end

    def alive?
      @hp > 0
    end

    def attacked_for(amount)
      @hp -= amount
    end
  end

  step "there is a knight" do
    self.knight = Knight.new
  end

  step "the knight is alive" do
    knight.should be_alive
  end

  step "the knight is dead" do
    knight.should_not be_alive
  end
end

RSpec.configure { |c| c.include KnightSteps, :knight => true }
