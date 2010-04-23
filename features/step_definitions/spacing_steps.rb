$:.unshift(File.dirname(__FILE__) + '/../../lib')
require 'tailor/indentation_checker'
require 'tailor/file_line'

include Tailor
include Tailor::IndentationChecker

#-----------------------------------------------------------------------------
# "Given" statements
#-----------------------------------------------------------------------------
Given /^that file contains lines with hard tabs$/ do
  @ruby_source = File.open(@file_list[0], 'r')
  contains_hard_tabs = false
  @ruby_source.each_line do |line|
    source_line = Tailor::FileLine.new line
    if source_line.hard_tabbed?
      contains_hard_tabs = true
      break
    end
  end
  contains_hard_tabs.should be_true
end

Given /^that file does not contain any "([^\"]*)" statements$/ do |keyword|
  @ruby_source = File.open(@file_list[0], 'r')

  count = count_keywords(@ruby_source, keyword)
  count.should == 0
end

Given /^that file is indented properly$/ do
  @file_list.each do |file|
    Tailor::IndentationChecker.validate_indentation file
  end
end

Given /^that file contains lines with trailing whitespace$/ do
  @ruby_source = File.open(@file_list[0], 'r')

  @ruby_source.each_line do |line|
    source_line = Tailor::FileLine.new line

    @whitespace_count = source_line.trailing_whitespace_count

    @whitespace_count.should > 0
  end
end

Given /^that file contains lines longer than 80 characters$/ do
  @ruby_source = File.open(@file_list[0], 'r')

  @ruby_source.each_line do |line|
    source_line = Tailor::FileLine.new line

    if source_line.too_long?
      too_long = true
      break
    else
      too_long = false
    end

    too_long.should be_true
  end
end


#-----------------------------------------------------------------------------
# "When" statements
#-----------------------------------------------------------------------------
When "I run the checker on the project" do
  @result = `#{@tailor} #{@project_dir}`
end

#-----------------------------------------------------------------------------
# "Then" statements
#-----------------------------------------------------------------------------
Then /^the checker should tell me each line that has a hard tab$/ do
  @result.should include("Line is hard-tabbed")
end

Then "the checker should tell me my indentation is OK" do
  pending
end

Then /^the checker should tell me each line has trailing whitespace$/ do
  message= "Line contains #{@whitespace_count} trailing whitespace(s)"
  @result.should include message
end

Then /^the checker should tell me each line is too long$/ do
  msg = "Line is greater than #{Tailor::FileLine::LINE_LENGTH_MAX} characters"
  @result.should include msg
end