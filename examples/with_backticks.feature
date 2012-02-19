Feature: A feature with backticks
  Scenario: This is a feature with backticks
    Given there is a monster
    When I run `killall monsters`
    Then it should die
