Given /^the file "([^\"]*)" in "([^\"]*)"$/ do |file, dir|

  @sgf1 = SGF::Tree.new :filename => "#{dir}#{file}"
  #When "I open then save \"#{dir}#{file}\""
  #Then "I should get no errors"
end

Given /^the destination file "([^\"]*)" in "([^\"]*)"$/ do |file, dir|
  @file2 = "#{dir}#{file}"
end




When /^I save the file$/ do  
  @sgf1.save :filename => @file2
end

Then /^both files should be the same$/ do
  file1 = File.readlines @file1
  file2 = File.readlines @file2
  file1.should == file2
end
