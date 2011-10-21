Feature: Feature with background
  Background:
    Given there is a monster
  Scenario: simple scenario
    When I attack it
    Then it should die
