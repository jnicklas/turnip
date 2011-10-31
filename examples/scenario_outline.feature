Feature: using scenario outlines
  Scenario Outline: a simple outline
    Given there is a monster with <hp> hitpoints
    When I attack the monster and do <damage> points damage
    Then the monster should be <state>

    Examples:
      | hp   | damage | state   |
      | 10   | 13     | dead    |
      | 8    | 5      | alive   |
