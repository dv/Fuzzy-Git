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
      regexp = create_fuzzy_regexp(pattern)
      files = []
      modified_files.each do |file|
        if file[0].match regexp
          files << file[0]
        end
      end

      if files.count == 0
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

    def create_fuzzy_regexp(pattern)
      regexp = ""
      pattern.each_char do |c|
        regexp += Regexp.escape(c) + ".*"
      end

      /#{regexp}/
    end

    def no_change_death
      puts "nothing happened."
      exit
    end
end


FuzzyGitAdd.new.run
