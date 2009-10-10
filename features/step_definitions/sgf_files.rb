Given /^The file "([^\"]*)" in "([^\"]*)"$/ do |file, dir|
  When "I parse \"#{dir}#{file}\""
  Then 'I should get no errors'

end

When /^I parse "([^\"]*)"$/ do |file|
  @tree = SGFTree.new :filename => file
end

Then /^I should get no errors$/ do
  @tree.class == SGFTree
end
