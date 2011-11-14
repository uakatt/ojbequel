module OJBequel
  # A module with some {OJBequel} utilities. For now, these should be accessible to anything inside
  # the {OJBequel} namespace, as the `lib/ojbequel.rb` file calls `include OJBequel::Utils`. This is
  # a good place to put methods that would be nice to have accessible from an irb session.
  module Utils
    # Creates a pipe to `less -R -F` via `IO.popen`, inspired by pry. This is used, for example,
    # to view the definition or OJB entry of a Sequel::Model class created from {OJBequel::RBStringFactory}.
    def less(string)
      IO.popen("less -R -F", "w") do |less|
        less.puts string
      end
    end
  end
end
