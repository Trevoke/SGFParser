Given /^The file "([^\"]*)" in "([^\"]*)"$/ do |file, dir|
  @file1 = "#{dir}#{file}"
end

When /^I parse "([^\"]*)"$/ do |file|
  @tree = SGF::Tree.new :filename => file
end

Then /^I should get no errors$/ do
  @tree.class.should == SGF::Tree
end