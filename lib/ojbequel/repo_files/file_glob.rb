require 'find'

# Use FileGlob if the OJB repository files can simply be gathered by matching file globs. If the
# order of the OJB repository files matters (as it often does, like if one repository overrides
# the `<class-definition>`'s of another), then a different class, like
# {OJBequel::RepoFiles::SpringLoad}, might be more useful.
class OJBequel::RepoFiles::FileGlob < OJBequel::RepoFiles::Base
  attr_accessor :files, :base_dir, :file_re

  # Create a new {OJBequel::RepoFiles::FileGlob} to maintain a hash of OJB repository files, in
  # (`name` : `path`) Hash format.
  #
  # @param [String] base_dir the base directory of the project that uses OJB
  # @param [RegExp] file_re the regular expression that will match an OJB repository file; it must
  #   contain at least one active group, which will be used for the name of the file (the key to
  #   the Hash).
  #
  # @example Save names of OJB files like "ojb-foo.xml"
  #   OJBequel::RepoFiles::FileGlob.new('/java/projects/kfs', /ojb-(.+?).xml$/
  def initialize(base_dir, file_re)
    @base_dir = base_dir
    @file_re  = file_re
  end

  # Find all OJB repository files, using the base directory, and the regular expression provided
  # when the {OJBequel::RepoFiles::FileGlob} was created. This method skips any files with `.svn`
  # in the path.
  #
  # @todo Raise a better exception if no active group existed in the regular expression.
  # @return the `@files` instance variable that this method creates
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
