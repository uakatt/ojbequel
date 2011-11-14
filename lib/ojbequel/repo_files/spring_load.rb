# Use SpringLoad if the OJB repository files are all indicated in a Spring XML file or a Spring
# properties file.
class OJBequel::RepoFiles::SpringLoad < OJBequel::RepoFiles::Base
  attr_accessor :files, :spring_bootstrap_file, :type

  # Create a new {OJBequel::RepoFiles::SpringLoad} to maintain a hash of OJB repository files, in
  # (`name` : `path`) Hash format.
  #
  # @param [String] spring_bootstrap_file the Spring bootstrap file (either a properties file or
  #   an XML file) of the project that uses OJB. This file is expected to point to Spring XML files
  #   that each reference one or more OJB repository files.
  # @param [optional Hash] options If `spring_bootstrap_file` ends in ".xml" or ".properties", the file
  #   type will be figured out automatically. Otherwise, you can specify `:type => :xml` or
  #   `:type => :properties`.
  #
  # @example Save names of OJB files like "ojb-foo.xml"
  #   OJBequel::RepoFiles::FileGlob.new('/java/projects/kc/src/main/resources/kc-bootstrap-springbeans.xml')
  def initialize(spring_bootstrap_file, options={})
    @spring_bootstrap_file = spring_bootstrap_file
    if @spring_bootstrap_file =~ /\.xml$/
      @type = :xml
    elsif @spring_bootstrap_file =~ /\.properties$/
      @type = :properties
    end
  end

  # Find all OJB repository files, using the base directory, and the regular expression provided
  # when the {OJBequel::RepoFiles::FileGlob} was created. This method skips any files with `.svn`
  # in the path.
  #
  # @todo Raise a better exception if no active group existed in the regular expression.
  # @return the `@files` instance variable that this method creates
  def find()
    find_by_xml        if @type == :xml
    find_by_properties if @type == :properties
    raise StandardError  # what is the file type?!?
  end
end
