Given /^I don't have a node$/ do
  @node = nil
end

When /^I create a new node$/ do
  @node = SGF::Node.new
end

Then /^I should get a new lone node$/ do
  @node.properties.should == {}
  @node.children.should == []
end

Given /^I don't have a tree$/ do
  @tree = nil
end

When /^I create a tree$/ do
  @tree = SGF::Tree.new
end

Then /^I should have a working, empty tree$/ do
  @tree.class.should == SGF::Tree
  @tree.root.class.should == SGF::Node
end
