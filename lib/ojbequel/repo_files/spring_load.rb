# Use SpringLoad if the OJB repository files are all indicated in a Spring XML file or a Spring
# properties file.
class OJBequel::RepoFiles::SpringLoad < OJBequel::RepoFiles::Base
  attr_accessor :files, :spring_bootstrap_file, :repo_re, :spring_base_dir, :type

  # Create a new {OJBequel::RepoFiles::SpringLoad} to maintain a hash of OJB repository files, in
  # (`name` : `path`) Hash format.
  #
  # @param [String] spring_bootstrap_file the Spring bootstrap file (either a properties file or
  #   an XML file) of the project that uses OJB. This file is expected to point to Spring XML files
  #   that each reference one or more OJB repository files.
  # @param [RegExp] file_re the regular expression that will match an OJB repository file; it must
  #   contain at least one active group, which will be used for the name of the file (the key to
  #   the Hash). Up to four active groups are supported.
  # @param [Hash] options various options
  # @option options [Symbol] :type If `spring_bootstrap_file` ends in ".xml" or ".properties", the file
  #   type will be figured out automatically. Otherwise, you can specify `:type => :xml` or
  #   `:type => :properties`.
  #
  # @example Save names of OJB files like "ojb-foo.xml"
  #   OJBequel::RepoFiles::FileGlob.new('/java/projects/kc/src/main/resources/kc-bootstrap-springbeans.xml')
  def initialize(spring_bootstrap_file, repo_re, options={})
    @spring_bootstrap_file = spring_bootstrap_file
    @repo_re = repo_re
    @spring_base_dir = File.dirname(@spring_bootstrap_file)
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
    return find_by_xml        if @type == :xml
    return find_by_properties if @type == :properties
    raise StandardError  # what is the file type?!?
  end

  def find_by_properties
    @files = {}
    property = 'spring.source.files'
    lines = File.readlines(@spring_bootstrap_file)
    source_files_line = lines.select { |line| line.index(property) == 0 }
    source_files_line = source_files_line[0]
    spring_files = source_files_line.split('=', 2)[1]
    spring_files = spring_files.split(',')
    spring_files.each do |f|
      begin
        find_in_spring_file(f.chomp)
      rescue Errno::ENOENT => e
        if e.to_s =~ /- (.+?)$/
          puts "ERROR: skipping file: #{$1}"
        else
          puts "ERROR: File not found: #{e}"
        end
      end
    end
    @files
  end

  # @todo Figure out something better than StandardError
  def find_in_spring_file(file)
    xml = Nokogiri::XML(File.read(File.join(@spring_base_dir, file)))
    xml.remove_namespaces!

    # Looking for:
    # <property name="databaseRepositoryFilePaths">
    #   <list>
    #     <value>org/kuali/kfs/module/purap/ojb-purap.xml</value>
    #   </list>
    # </property>
    databaseRepositoryFilePaths = xml.xpath("//property[@name='databaseRepositoryFilePaths']")
    databaseRepositoryFilePaths.each do |node|
      node.xpath("list/value").each do |value|
        if value.text =~ @repo_re
          raise StandardError if $1.nil?
          name = $1 + ($2 || '') + ($3 || '') + ($4 || '')
          #puts "Inserting @files[#{name}] = #{File.join(@spring_base_dir, value.text.split('/'))}"
          @files[name] = File.join(@spring_base_dir, value.text.split('/'))
        else
          raise StandardError
        end
      end
    end
  end
end
