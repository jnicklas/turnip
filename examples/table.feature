Feature: A feature with tables
  Scenario: This is a feature with a table
    Given there are the following monsters:
      | Name    | Hitpoints |
      | Blaaarg | 23        |
      | Moorg   | 12        |
    Then "Blaaarg" should have 23 hitpoints
    And "Moorg" should have 12 hitpoints
