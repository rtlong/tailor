require 'treetop'
require 'polyglot'
require './style'
#require 'tailor/simple_html'
require 'pp'

f = File.open('../../../features/support/1_file_with_bad_comma_spacing/bad_comma_spacing.rb', 'rb')
text = f.read

#text = "This is some text\nSecond line,bobo\n  Third line, meow"
parser = StyleParser.new

result = parser.parse text
puts result
puts result.inspect
pp result.values
#puts result.elements
#puts result.elements.methods
#puts result.elements.inspect
#puts result.values if result
#result.values.each {|v| puts v[:values]}
=begin
puts 'stuf...'
puts result.line
puts result.line.values
puts
puts
puts
puts result.more
puts result.input
puts result.interval
puts result.parent
puts result.elements
=end