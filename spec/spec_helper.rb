begin
  require 'spec'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  gem 'rspec'
  require 'spec'
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.unshift(File.dirname(__FILE__) + '/../lib/tailor/grammars')
require 'tailor'
require 'pp'

def create_file_line(string, line_number)
  FileLine.new(string, Pathname.new(__FILE__), line_number)
end
