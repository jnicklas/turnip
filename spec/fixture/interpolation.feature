Feature: A simple feature
  Scenario: Interpolation with quotes
    Given there is a monster called "John Smith"
    Then it should be called "John Smith"

  Scenario: Interpolation without quotes
    Given there is a monster called John
    Then it should be called "John"

  Scenario: Interpolation with customer regexp
    Given there are 3 monkeys with blue hair
    Then there should be 3 monkeys with blue hair
