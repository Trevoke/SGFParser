Given /^the file "([^\"]*)" in "([^\"]*)"$/ do |file, dir|
  @sgf1 = SGF::Tree.new :filename => "#{dir}#{file}"
end

Given /^the destination file "([^\"]*)" in "([^\"]*)"$/ do |file, dir|
  @file2 = "#{dir}#{file}"
end

When /^I save the file$/ do  
  @sgf1.save :filename => @file2
end

Then /^both files should be the same$/ do
  @sgf2 = SGF::Tree.new :filename => @file2
  @sgf1.should == @sgf2
end
