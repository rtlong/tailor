require File.dirname(__FILE__) + '/../spec_helper.rb'
require 'citrus'

describe RubyString do
  context "#ruby_curly_block" do
    it "should parse empty curly braces" do
      r = RubyString.parse('{}', :root => :ruby_curly_block)
      r.should == '{}'
    end

    it "should parse curly braces with a variable" do
      r = RubyString.parse('{ some_var }', :root => :ruby_curly_block)
      r.should == '{ some_var }'
    end

    it "should parse curly braces of a Hash" do
      r = RubyString.parse('{ :some_key => {} }', :root => :ruby_curly_block)
      r.should == '{ :some_key => {} }'
    end
  end

  context "#ruby_curly_source" do
    it "should parse some method call" do
      r = RubyString.parse('some_call', :root => :ruby_curly_source)
      r.should == 'some_call'
    end

    it "should parse a method call with a block" do
      r = RubyString.parse('some_call_with_a_block {}', :root => :ruby_curly_source)
      r.should == 'some_call_with_a_block {}'
    end
  end

  context "#string_interpolation" do
    it "should parse an empty string in interpolation" do
      r = RubyString.parse('#{}', :root => :string_interpolation)
      r.should == '#{}'
    end

    it "should parse a variable in interpolation" do
      r = RubyString.parse('#{some_var}', :root => :string_interpolation)
      r.should == '#{some_var}'
    end

    it "should parse a variable in interpolation with bad style" do
      r = RubyString.parse('#{ some_var }', :root => :string_interpolation)
      r.should == '#{ some_var }'
      r.malformed?.should be_true
    end

    it "should parse a {}.to_s in interpolation" do
      r = RubyString.parse('#{some_call {}.to_s}', :root => :string_interpolation)
      r.malformed?.should be_false
    end

    it "should parse a {}.to_s in interpolation with bad style" do
      r = RubyString.parse('#{ some_call {}.to_s }', :root => :string_interpolation)
      r.malformed?.should be_true
    end
  end

  context "#single_quoted_string" do
    it "should parse an empty single quoted string" do
      r = RubyString.parse("''", :root => :single_quoted_string)
      r.should == "''"
    end

    it "should parse a single quoted string with text in it" do
      r = RubyString.parse("'some text'", :root => :single_quoted_string)
      r.should == "'some text'"
    end
  end

  context "#double_quoted_string" do
    it "should parse an empty double quoted string" do
      r = RubyString.parse('""', :root => :double_quoted_string)
      r.should == '""'
    end

    it "should parse a double quoted string with text in it" do
      r = RubyString.parse('"some text"', :root => :double_quoted_string)
      r.should == '"some text"'
    end

    it "should parse a double quoted string with text and interpolation" do
      r = RubyString.parse('"some text #{some_var}"', :root => :double_quoted_string)
      r.contains_malformed_interpolation?.should be_false
    end

    it "should parse a double quoted string with text and interpolation with bad style" do
      r = RubyString.parse('"some text #{ some_var }"', :root => :double_quoted_string)
      r.contains_malformed_interpolation?.should be_true
    end
  end
end