class OJBequel::RepoFiles
  # The base class for all {OJBequel::RepoFiles} classes. This class does not provide too many
  # methods that inheriting classes will be provided, but there is at least {#each}.
  class Base
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
