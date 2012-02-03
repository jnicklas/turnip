@runner
Feature:

  Scenario:
    Given I start as a beginner runner
    When I run for 10 minutes
    Then I should have run 1 miles

    When I become an advanced runner
    And I run for 10 minutes
    Then I should have run 2 miles
