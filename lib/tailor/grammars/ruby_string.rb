Citrus.eval(<<'CODE')
grammar RubyString
  rule string
    single_quoted_string | double_quoted_string
  end

  # This should be expanded to account for escaped single quotes.
  rule single_quoted_string
    "'" (!"'" .)* "'"
  end

  # This should be expanded to account for escaped double quotes.
  rule double_quoted_string
    ('"' (string_interpolation | !'"' .)* '"') {
			def malformed?
				contains_malformed_interpolation?
			end

      def interpolations
        find(:string_interpolation)
      end

      def contains_malformed_interpolation?
        interpolations.any? {|s| s.malformed? }
      end
    }
  end

  rule string_interpolation
    ('#{' ruby_curly_source '}') {
      def malformed?
        !! (ruby_curly_source.text =~ /^\s|\s$/)
      end
    }
  end

  # Ruby source code that may be contained inside curly braces.
  rule ruby_curly_source
    (!'}' (ruby_curly_block | .))*
  end

  rule ruby_curly_block
    '{' ruby_curly_source '}'
  end
end
CODE