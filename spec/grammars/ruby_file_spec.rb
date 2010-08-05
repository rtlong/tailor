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
    it "should find a line" do
      r = RubyFile.parse('s = "This is a string"')
      lines = r.find(:line)
      lines.class.should == Array
      lines.length.should == 1
    end

    it "should find 2 lines" do
      r = RubyFile.parse("s = \"This is a string\"\nt = String.new")
      lines = r.find(:line)
      lines.class.should == Array
      lines.length.should == 2
    end

    it "should find a string" do
      r = RubyFile.parse('s = "This is a string"')
      strings = r.find(:string)
      strings.class.should == Array
      strings.length.should == 1
    end

    it "should find 2 strings" do
      r = RubyFile.parse('s = "This is a string"\nt = "Another string!"')
      strings = r.find(:string)
      strings.class.should == Array
      strings.length.should == 2
    end

    it "should find 0 strings" do
      r = RubyFile.parse('s = String.new')
      strings = r.find(:string)
      strings.class.should == Array
      strings.length.should == 0
    end
  end

  context "reports problems" do
    context "with strings" do
      context "with bad interpolation" do
        it "when on first line" do
          r = RubyFile.parse("\"This is \#{ foo }\"\ndef blah;end;")
          r.style_errors.first[:problem_text].should == "\"This is \#{ foo }\""
          r.style_errors.first[:summary].should == "Bad string interpolation"
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

        it "should report 0 problems with NO bad string interpolation" do
          r = RubyFile.parse("\"This is \#{foo}\"\n\"This is \#{bar}\"")
          r.style_errors.should be_empty
        end
      end
    end

    context "with hard tabs" do
      it "should report a hard tab at the beginning of the line" do
        r = RubyFile.parse("\t\"This is \#{foo}\"")
        r.style_errors.first[:problem_text].should == "\t"
        r.style_errors.first[:summary].should == "[Spacing]  Line contains hard tabs"
      end

      it "should NOT report 0 hard tabs at the beginning of the line" do
        r = RubyFile.parse("\"This is \#{foo}\"")
        r.style_errors.should be_empty
      end
    end

    context "with lines" do
      it "should report a line > 80 characters" do
        s = ' ' * 81
        r = RubyFile.parse(s)
        r.malformed?.should be_true
        r.style_errors.first[:problem_text].should == s
        r.style_errors.first[:summary].should == "Line is >80 characters (81)"
      end

      it "should NOT report a line == 80 characters" do
        s = ' ' * 80
        r = RubyFile.parse(s)
        r.malformed?.should be_false
        r.style_errors.should be_empty
      end
    end
  end
end