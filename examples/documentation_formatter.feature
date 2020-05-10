Feature: Documentation formatter examples
  Scenario: Passing
    Given there is a monster
    When I attack it
    Then it should die

  Scenario: Error
    Given there is a monster
    When I attack it
    And raise error
    Then it should die

  Scenario: Pending
    Given there is a monster
    When I attack it
    And do something unexpected
    Then it should die
