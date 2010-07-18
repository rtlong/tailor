require 'spec_helper.rb'
require 'treetop'
require 'polyglot'
require 'tailor/grammars/style'
require 'pp'

f = File.open('../features/support/1_file_with_bad_comma_spacing/bad_comma_spacing.rb', 'rb')
text = f.read

#text = "This is some text\nSecond line,bobo"
parser = StyleParser.new
#puts parser.parse(c)
#puts parser.parse(c).content
lines =  parser.parse(text).values
pp lines
