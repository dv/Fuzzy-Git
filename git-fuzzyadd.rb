#!/usr/bin/env ruby
#
# Searches changed but not updated files for matches with the
# given fuzzy pattern and adds them to the git repo.
#
# Copyright (c) 2011 by David Verhasselt (david@crowdway.com)
# 
# Licensed under the MIT License. See included file LICENSE
#

class FuzzyGitAdd
  def initialize
  end

  def run
    if ARGV.count == 0
      no_change_death
    end

    ARGV.each do |pattern|
      files = find_first_matches(modified_files, pattern)

      if files.nil?
        puts "#{pattern} matches no files."
        no_change_death        

      elsif files.count > 1
        puts "#{pattern} matches #{files.count} files, please specify:"
        files.each do |file|
          puts "        #{file}\n"
        end
        no_change_death

      else
        puts "added #{files[0]}."
        system "git add #{files[0]}"
      end
    end
  end

  private
    # Returns array with all changed but not updated files
    # ["filename3.txt"]
    def modified_files
      `git status -sz`.scan(/ M ([^\0]+)\0/)
    end

    # Returns array as follows:
    # [
    #   ["M", " ", "filename1.txt"],
    #   ["?", "?", "filename2.txt"],
    #   [" ", "M", "filename3.txt"]
    # ]
    def status_files
      `git status -sz`.scan(/([^\0])([^\0]) ([^\0]+)\0/)
    end

    def find_first_matches(files, pattern)
      matches = []

      (0..5).each do |stage|
        regexp = create_fuzzy_regexp(pattern, stage)
        files.each do |file|
          if file[0].match regexp
            matches << file[0]
          end
        end

        unless matches.empty?
          return matches
        end
      end
    end


    def create_fuzzy_regexp(pattern, stage = 0)
      path_re = ""
      filename = pattern

=begin
        stage 0: no wildcards (whole word)
        stage 1: wildcards around directory names, no wildcards around filename
        stage 2: wildcards around directory names, wildcards around whole filename (no slashes after filename)
        stage 3: wildcards around directory names, wildcards around whole filename
        stage 4: wildcards around directory names, wildcard in front of filename and around extension-dot
        stage 5: wildcards around every character
=end
      
      if pattern.index("/") and (1..3).contains(stage)
        path = filename.split("/")
        filename = path.pop

        path.each do |dir|
          path_re += ".*#{dir}.*/"
        end
      end

      case stage
        when 0
          /#{pattern}/
    
        when 1
          /#{path_re}#{filename}/

        when 2
          /#{path_re}.*#{filename}[^\/]*/

        when 3
          /#{path_re}.*#{filename}.*/

        when 4
          if not filename.index(".")
            create_fuzzy_regexp(pattern, 3)  
          else
            path_re += ".*\..*" + filename.split(".").join(".*\..*")
            /#{path_re}/
          end

        when 5
          regexp = ""
          pattern.each_char do |c|
            regexp += Regexp.escape(c) + ".*"
          end
          /#{regexp}/
      end
    end

    def no_change_death
      puts "nothing happened."
      exit
    end
end

if __FILE__ == $0
  FuzzyGitAdd.new.run
end
