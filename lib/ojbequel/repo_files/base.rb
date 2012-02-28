class OJBequel::RepoFiles
  # The base class for all {OJBequel::RepoFiles} classes. This class does not provide too many
  # methods that inheriting classes will be provided...
  class Base

    # Load all of the class definitions from the repository files that have been loaded into `@files`.
    #
    # @param [OJBequel::ModelFactory::Base] factory a class that inherits from
    #   {OJBequel::ModelFactory::Base} (not an instance, we need the class itself). {#load} will
    #   create an instance of this class, save it to a variable, and call that instance's {#build}
    #   method.
    def load(factory)
      @files.each do |name, file|
        puts "Creating #{name} repository (#{file})..."
        repository = OJBequel::Repository.new(file)
        repository.parse
        Factories[name] = factory.new(repository)
        repository.class_descriptors.each do |cd|
          Factories[name].build(cd.rb_klazz)
        end
        Repositories[name] = repository
      end
    end

    # Allows us to treat a {OJBequel::RepoFiles::Base} object simply as the hash of files
    # (`name` : `path`) that it contains. Can call `#each` on a {OJBequel::RepoFiles::Base} object
    # without calling `#find`. `#each` will call `#find` itself if `@files` is `nil`.
    #
    # I do it this way because I've heard people rail against extending Hash, etc.
    def method_missing(method_name, *args, &block)
      @files || find
      if @files.respond_to? method_name
        if block_given?
          @files.send(method_name, *args, &block)
        else
          @files.send(method_name, *args)
        end
      else
        raise NoMethodError
      end
    end
  end
end
