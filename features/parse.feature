Feature: parse SGF files
  As a user, I want to open SGF files so I can enjoy the goodness.

  Scenario: Parse the sample ff4 file
    Given The file "ff4_ex.sgf" in "features/samples/"
    When I parse "features/samples/ff4_ex.sgf"
    Then I should get no errors

  Scenario: Parse a sample KGS file
    Given The file "redrose-tartrate.sgf" in "features/samples/"
    When I parse "features/samples/redrose-tartrate.sgf"
    Then I should get no errors