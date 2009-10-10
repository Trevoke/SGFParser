Feature: Create a tree
  As a user, I want to create a tree so that I can browse information about a game
  
  Scenario:
    Given I don't have a node
    When I create a new node
    Then I should get a new lone node


  Scenario:
    Given I don't have a tree
    When I create a tree
    Then I should have a working, empty tree