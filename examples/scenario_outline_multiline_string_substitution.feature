Feature: using scenario outlines
  Scenario Outline: a simple outline
    Given there is a monster called <name>
    Then the monster introduced himself:
      """
      Ahhhhhhh! i'm <name>!
      """

    Examples:
      | name          |
      | John          |
      | "John Smith"  |
      | "O'Flannahan" |
