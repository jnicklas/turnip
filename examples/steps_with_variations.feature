Feature: steps with variations, such as alternative words or optional words
  Scenario: alternative words
    Given there is a strong monster
    Then it should be strong
    And it should be tough
  Scenario: optional words
    Given there is a strong monster
    Then it should be badass
    And it should be a badass
  Scenario: optional parts of words
    Given there is a strong monster
    Then it should be terrible
    And it should be terriblest
  Scenario: putting it all together
    Given there is a strong monster
    Then it should have 2 terrifying hitpoints
    And it has 2 hitpoint
