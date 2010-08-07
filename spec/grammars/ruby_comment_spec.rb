require File.dirname(__FILE__) + '/../spec_helper.rb'
require 'citrus'
require 'citrus/debug'
Citrus.load '../../lib/tailor/grammars/ruby_comment'

describe RubyComment do
  #context "from the parent rule" do
  #end
  
  context "from each comment type rule" do
    it "should detect a begin/end comment" do
      s = "=begin\nclass Test\n=end"
      r = RubyComment.parse(s, :root => :begin_end_comment)
      r.should == s
    end
  end
end