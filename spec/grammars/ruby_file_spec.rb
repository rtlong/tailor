require File.dirname(__FILE__) + '/../spec_helper.rb'
require 'citrus'

describe RubyFile do
  context "line counting" do
    it "should count 2 lines of code with a bad string interpolation" do
      r = RubyFile.parse("\"This is \#{ foo }\"\ndef blah;end;")
      r.find(:line).count.should == 2

      s = r.find :double_quoted_string
      s.first.malformed?.should == true
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

    it "should find 0 strings" do
      r = RubyFile.parse('s = String.new')
      r.strings.class.should == Array
      r.strings.length.should == 0
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

  context "line counting AND problem reporting" do
    context "should report problem and the line it's on" do
      it "when on first line" do
        r = RubyFile.parse("\"This is \#{ foo }\"\ndef blah;end;")
        r.style_errors.length.should == 1
        r.style_errors.first[:line].should == 1
        r.style_errors.first[:problem_text].should == "\"This is \#{ foo }\""
      end

      it "when on second line" do
        r = RubyFile.parse("# Comment line\n\"This is \#{ foo }\"\ndef blah;end;")
        r.style_errors.length.should == 1
        r.style_errors.first[:line].should == 2
        r.style_errors.first[:problem_text].should == "\"This is \#{ foo }\""
      end

      it "when on first and third line" do
        r = RubyFile.parse("\"This is \#{ foo }\"\ndef blah;end;\n\"This is \#{ foo}\"")
        r.style_errors.length.should == 2
        r.style_errors[0][:line].should == 1
        r.style_errors[0][:problem_text].should == "\"This is \#{ foo }\""
        r.style_errors[1][:line].should == 3
        r.style_errors[1][:problem_text].should == "\"This is \#{ foo}\""
      end

      it "when on second and fourth line" do
        r = RubyFile.parse("# Comment Line\n\"This is \#{ foo }\"\ndef blah;end;\n\"This is \#{ foo}\"")
        r.style_errors.length.should == 2
        r.style_errors[0][:line].should == 2
        r.style_errors[0][:problem_text].should == "\"This is \#{ foo }\""
        r.style_errors[1][:line].should == 4
        r.style_errors[1][:problem_text].should == "\"This is \#{ foo}\""
      end
    end
  end
end