require File.expand_path(File.dirname(__FILE__)) + '/ruby_string.rb'

Citrus.eval(<<'CODE')
grammar RubyFile
	include RubyString

	rule file
		lines
	end

	rule lines
		line* {
			def line_count
				count = 1
				count += 1 if line
			end
		}
	end

	rule line
		(string | .) &[\n]?
	end
end
CODE
