class OJBequel::RepoFiles
  class Base
    def each(&p)
      (@files || find).each(&p)
    end
  end
end
