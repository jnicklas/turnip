@before
Feature: Feature with before steps in steps file
  
  Scenario: can stick some before / after stuff in the steps file
    Given a step
    Given b step

  Scenario: can run a before step before each scenario
    Given a step
    Given b step
  
