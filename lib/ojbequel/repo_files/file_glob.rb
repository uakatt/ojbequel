require 'find'

class OJBequel::RepoFiles::FileGlob < OJBequel::RepoFiles::Base
  attr_accessor :files, :base_dir, :file_re

  def initialize(base_dir, file_re)
    @base_dir = base_dir
    @file_re  = file_re
  end

  def find
    @files = {}
    Find.find(@base_dir) do |path|
      next if path =~ /\.svn/
      if path =~ @file_re
        raise StandardError if $1 == nil
        @files[$1] = path
      end
    end
    @files
  end
end
