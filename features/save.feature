Feature: save SGF files
  As a user, I want to save SGF files to view them later.

  Scenario: Open / save the sample ff4 file
    Given the file "ff4_ex.sgf" in "features/samples/"
      And the destination file "save_sample1.sgf" in "features/samples/" 
    When I save the file
    Then both files should be the same