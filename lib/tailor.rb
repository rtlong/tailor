$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) ||
  $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'fileutils'
require 'pathname'
require 'citrus'
Citrus.load(File.expand_path(File.dirname(__FILE__) + '/tailor/grammars/ruby_string'))
Citrus.load(File.expand_path(File.dirname(__FILE__) + '/tailor/grammars/ruby_file'))

module Tailor
  VERSION = '0.1.1'

  # These operators should always have 1 space around them
  OPERATORS = {
    :arithmetic => ['+', '-', '*', '/', '%', '++', '--', '**'],
    :assignment => ['=', '+=', '-=', '*=', '/=', '%=', '*=', '**=', '|', '&=',
      '&&=', '>>=', '<<=', '||='],
    :comparison => ['==', '===', '!=', '>', '<', '>=', '<=', '<=>', '!', '~'],
    :gem_version => ['~>'],
    :logical => ['&&', '||', 'and', 'or'],
    :regex => ['^', '|', '!~', '=~'],
    :shift => ['<<', '>>'],
    :ternary => ['?', ':']
  }

  # These operators should never have spaces around them
  NO_SPACE_AROUND_OPERATORS = {
    :range => ['..', '...'],
    :scope_resolution => ['::']
  }

  # Don't do anything about these ops; they're just here so we know not to do
  # anything with them.
  DO_NOTHING_OPS = {
    :elements => ['[]', '[]=']
  }

  # Check all files in a directory for style problems.
  #
  # @param [String] project_base_dir Path to a directory to recurse into and
  #   look for problems in.
  # @return [Hash] Returns a hash that contains file_name => problem_count.
  def self.check project_base_dir
    # Get the list of files to process
    ruby_files_in_project = project_file_list(project_base_dir)

    files_and_problems = Hash.new

    # Process each file
    ruby_files_in_project.each do |file_name|
      problems = find_problems_in file_name
      files_and_problems[file_name] = problems
      break
    end

    files_and_problems
  end

  # Gets a list of .rb files in the project.  This gets each file's absolute
  #   path in order to alleviate any possible confusion.
  #
  # @param [String] base_dir Directory to start recursing from to look for .rb
  #   files
  # @return [Array] Sorted list of absolute file paths in the project
  def self.project_file_list base_dir
    if File.directory? base_dir
      FileUtils.cd base_dir
    end

    # Get the .rb files
    ruby_files_in_project = Dir.glob(File.join('*', '**', '*.rb'))
    Dir.glob(File.join('*.rb')).each { |file| ruby_files_in_project << file }

    # Expand paths to all files in the list
    list_with_absolute_paths = Array.new
    ruby_files_in_project.each do |file|
      list_with_absolute_paths << File.expand_path(file)
    end

    list_with_absolute_paths.sort
  end

  # Checks a sing file for all defined styling parameters.
  #
  # @param [String] file_name Path to a file to check styling on.
  # @return [Number] Returns the number of errors on the file.
  def self.find_problems_in file_name
    source = File.open(file_name, 'r')
    file_path = Pathname.new(file_name)

    puts
    puts "#-------------------------------------------------------------------"
    puts "# Looking for bad style in:"
    puts "# \t'#{file_path}'"
    puts "#-------------------------------------------------------------------"

    @problem_count = 0

    r = RubyFile.parse(source.read)
    puts r.style_errors
    @problem_count += r.style_errors.length
    
    @problem_count
  end

  ##
  # Prints a summary report that shows which files had how many problems.
  #
  # @param [Hash] files_and_problems Returns a hash that contains
  #   file_name => problem_count.
  def self.print_report files_and_problems
    puts
    puts "The following files are out of style:"

    files_and_problems.each_pair do |file, problem_count|
      file_path = Pathname.new(file)
      unless problem_count == 0
        print "\t#{problem_count} problems in: "
        puts "#{file_path.relative_path_from(Pathname.pwd)}"
      end
    end
  end
end