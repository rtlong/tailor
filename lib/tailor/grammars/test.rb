require 'citrus'
require 'pp'

#Citrus.load 'bad_style'
#Citrus.load 'bad_comma_style'
Citrus.load 'ruby_string'

#f = File.open('../../../features/support/1_file_with_bad_comma_spacing/bad_comma_spacing.rb', 'rb')
f = File.open('../../../features/support/1_file_with_bad_curly_brace_spacing/bad_curly_brace_spacing.rb', 'rb')
text = f.read

begin
  #text = "\"This is some text\nSecond line,bobo\""
  #result = BadStyle.parse text
  result = RubyString.parse(text, :root => :string)
  #result = BadCommaStyle.parse text
  result.matches.each do |match|
    puts match.names
    puts match.text unless match.name == ''
  end
  
  interps = result.find :string_interpolation
  interps.each do |i|
    if i.malformed?
      puts "yes, #{i}"
    end
  end
  #pp result
rescue Citrus::ParseError => e
  puts e
  puts "e.backtrace #{e.backtrace}"
  puts "e.consumed #{e.consumed}"
  #puts "e.input.match #{e.input.match(/lines/)}"
  puts "e.max_offset #{e.max_offset}"
end
