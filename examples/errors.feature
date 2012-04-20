Feature: raises errors
  Scenario: Step missing
    When a step just does not exist
  Scenario: Step raises error
    When raise error
  Scenario: Incorrect expectation
    Given there is a monster
    Then it should die
