require File.dirname(__FILE__) + '/../spec_helper.rb'
require 'citrus'
require 'citrus/debug'
Citrus.load '../../lib/tailor/grammars/ruby_comment'

describe RubyComment do
  context "from the parent rule" do
    it "should detect a begin/end comment" do
      s = "=begin\nclass Test\n=end"
      r = RubyComment.parse(s)
      r.should == s
      r.names.should == [:begin_end_comment, :comment]
    end
  end
  
  context "from each comment type rule" do
    context "begin/end comment" do
      it "should detect" do
        s = "=begin\nclass Test\n=end"
        r = RubyComment.parse(s, :root => :begin_end_comment)
        r.should == s
        r.names.should == [:begin_end_comment]
      end

      it "should skip nested" do
        s = "=begin\nclass Test\n=begin\nend\n=end\n\n=end"
        r = RubyComment.parse(s, :root => :begin_end_comment)
        r.should == s
        r.names.should == [:begin_end_comment]
      end
    end

    context "full line comment" do
      it "should detect, no space before the #" do
        s = "# This is a comment"
        r = RubyComment.parse(s, :root => :full_line_comment)
        r.should == s
        r.names.should == [:full_line_comment]
      end

      it "should detect, no space before the #, with \\n at end" do
        s = "# This is a comment\n"
        r = RubyComment.parse(s, :root => :full_line_comment)
        r.should == s
        r.names.should == [:full_line_comment]
      end

      it "should detect, with space before the #" do
        s = "  # This is a comment"
        r = RubyComment.parse(s, :root => :full_line_comment)
        r.should == s
        r.names.should == [:full_line_comment]
      end

      it "should detect, with hard tabs before the #" do
        s = "\t\t# This is a comment"
        r = RubyComment.parse(s, :root => :full_line_comment)
        r.should == s
        r.names.should == [:full_line_comment]
      end
    end

    context "end line comment" do
      it "should detect, no other # usage" do
        s = "variable = 'hi' # This is a comment"
        r = RubyComment.parse(s, :root => :end_line_comment)
        r.should == s
        r.names.should == [:end_line_comment]
      end

      it "should detect, with newline at the end" do
        s = "variable = 'hi' # This is a comment\n"
        r = RubyComment.parse(s, :root => :end_line_comment)
        r.should == s
        r.names.should == [:end_line_comment]
      end

      it "should detect, with # in comment" do
        s = "variable = 'hi' # This is a # comment"
        r = RubyComment.parse(s, :root => :end_line_comment)
        r.should == s
        r.names.should == [:end_line_comment]
      end

      it "should detect, with string interpolation in comment" do
        s = "variable = 'hi' # This is a #{self} comment"
        r = RubyComment.parse(s, :root => :end_line_comment)
        r.should == s
        r.names.should == [:end_line_comment]
      end
    end
  end
end