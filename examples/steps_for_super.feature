Feature: Red Dragons are deadly

  @dragon
  Scenario:
    Given there is a dragon
    And there is a knight
    When the dragon attacks the knight
    Then the knight is alive

  @red_dragon
  Scenario:
    Given there is a dragon
    And the dragon breathes fire
    And there is a knight
    When the dragon attacks the knight
    Then the knight is dead
