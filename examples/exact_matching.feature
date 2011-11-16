Feature: Exact step matches should work

  Scenario: in the simple case
    Given an exact step
    When it is run
    Then it should execute
    
  Scenario: more complex case
    Given an exact step
    And another condition
    When it is run
    And we do something else
    Then it should execute
    And it should pass