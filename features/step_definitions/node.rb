Given /^I don't have a node$/ do
  When 'I create a new node'
  Then 'I should get a new lone node'
end

When /^I create a new node$/ do
  @node = SGFNode.new
end

Then /^I should get a new lone node$/ do
  @node.previous.nil?
  @node.next.empty?
end
