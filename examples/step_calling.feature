Feature: Step-calling steps
  
  Scenario: when the called step is visible
    Given a visible step call
  
  Scenario: when the called step is not visible
    Given an invisible step call
    
  Scenario: when the called step is global
    Given a global step call
  
  @dragon
  Scenario: when the called step is included via tag
    Given an included call