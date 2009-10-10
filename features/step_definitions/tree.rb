Given /^I don't have a tree$/ do
  When 'I create a tree'
  Then 'I should have a working, empty tree'
end

When /^I create a tree$/ do
  @tree = SGFTree.new
end

Then /^I should have a working, empty tree$/ do
  @tree.class == SGFTree
  @tree.root.class == SGFNode
end
