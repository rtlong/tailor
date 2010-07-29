require File.dirname(__FILE__) + '/../spec_helper.rb'
require 'citrus'

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

=begin
    it "should report problem and the line it's on" do
      r = RubyFile.parse("\"This is \#{ foo }\"\ndef blah;end;")
    end
=end
  end

  context "find Ruby types" do
    it "should find a string" do
      r = RubyFile.parse('s = "This is a string"')
      r.strings.class.should == Array
      r.strings.length.should == 1
    end

    it "should find 2 strings" do
      r = RubyFile.parse('s = "This is a string"\nt = "Another string!"')
      r.strings.class.should == Array
      r.strings.length.should == 2
    end
  end

  context "reports problems" do
    it "should report a problem with bad string interpolation" do
      r = RubyFile.parse("\"This is \#{ foo }\"\ndef blah;end;")
      r.style_errors.first.should == "\"This is \#{ foo }\""
    end
  end
end