Feature: A feature with multiline strings
  Scenario: This is a feature with multiline strings
    When the monster sings the following song
      """
        Oh here be monsters
        This is cool
      """
    Then the song should have 2 lines
