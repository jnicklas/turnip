@awesome
Feature: With tags
  @cool
  Scenario: Attack a monster with cool tag
    Given there is a monster
    When I attack it
    Then it should die

  @stealthy @wicked
  Scenario: With multiple tags
    Given there is a strong monster
    When I attack it
    And I attack it
    Then it should die
