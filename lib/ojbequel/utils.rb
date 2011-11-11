module KFSequel
  module Utils
    def less(string)
      IO.popen("less -R -F", "w") do |less|
        less.puts string
      end
    end
  end
end
