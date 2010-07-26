require File.dirname(__FILE__) + '/../spec_helper.rb'
require 'citrus'
Citrus.load '../../lib/tailor/grammars/ruby_file'

describe RubyFile do
  context "line counting" do
    it "should count 2 lines of code" do
      r = RubyFile.parse("line 1\nline 2\n")
      r.line_count.should == 2
    end

    it "should count 2 lines of code when no \\n appears at the end" do
      r = RubyFile.parse("line 1\nline 2")
      r.line_count.should == 2
    end

    it "should count 2 lines of code with a bad string interpolation" do
      r = RubyFile.parse("\"This is \#{ foo }\"\ndef blah;end;")
      r.line_count.should == 2

      s = r.find :double_quoted_string
      s.first.malformed?.should == true
    end
  end
end