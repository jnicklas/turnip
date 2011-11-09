Feature: Tagged steps for and super
  @dragon
  Scenario:
    Given there is a dragon
    Then the dragon attacks for 10 hitpoints

  @red_dragon
  Scenario:
    Given there is a dragon
    And it is a fire breathing red dragon
    Then the dragon attacks for 20 hitpoints
