@autoload_steps
Feature: Auto-loaded steps

  @scenario_tag
  Scenario: Deprecated auto-loaded step
    Given an auto-loaded step is available

  Scenario: Auto-loaded steps module
    Given a step auto-loaded by module
