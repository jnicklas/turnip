Feature: A simple feature
  Scenario: Interpolation with quotes
    Given there is a monster called "John Smith"
    Then it should be called "John Smith"

  Scenario: Interpolation without quotes
    Given there is a monster called John
    Then it should be called "John"
