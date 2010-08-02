require File.dirname(__FILE__) + '/../spec_helper.rb'
require 'citrus'

describe RubyFile do
  it "should do what I say" do
    r = RubyFile.parse("line 1\nline 2\n")
    puts r
    pp r
  end

  context "line counting" do
    it "should count 2 lines of code with a bad string interpolation" do
      r = RubyFile.parse("\"This is \#{ foo }\"\ndef blah;end;")

      s = r.find :double_quoted_string
      s.first.malformed?.should == true
    end

    it "should report problem and the line it's on" do
      r = RubyFile.parse("\"This is \#{ foo }\"\ndef blah;end;", :enable_memo => true)
      r.style_errors.length.should == 1
      r.style_errors.first[:line].should == 1
      r.style_errors.first[:problem_text].should == "\"This is \#{ foo }\""
    end
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
      r.style_errors.first[:problem_text].should == "\"This is \#{ foo }\""
    end

    it "should report 2 problems with bad string interpolation" do
      r = RubyFile.parse("\"This is \#{ foo }\"\n\"This is \#{ bar}\"")
      r.style_errors[1][:problem_text].should == "\"This is \#{ bar}\""
    end
  end
end