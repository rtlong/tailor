require 'citrus'
require 'pp'

Citrus.load 'bad_style'

f = File.open('../../../features/support/1_file_with_bad_comma_spacing/bad_comma_spacing.rb', 'rb')
text = f.read

begin
  #text = "This is some text\nSecond line,bobo"
  result = BadStyle.parse text
  pp result
rescue Citrus::ParseError => e
  puts e
  puts "e.backtrace #{e.backtrace}"
  puts "e.consumed #{e.consumed}"
  #puts "e.input.match #{e.input.match(/lines/)}"
  puts "e.max_offset #{e.max_offset}"
end
