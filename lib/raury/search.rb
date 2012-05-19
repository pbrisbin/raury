module Raury
  class Search
    def initialize(*arguments)
      @arguments = arguments
    end

    def search(quiet = false)
      results = Rpc.new(:search, *@arguments).call

      quiet ? puts(*results.map(&:name))
            :       results.map(&:display)

    rescue NoResults
      exit 1
    end

    def info
      results = Rpc.new(:multiinfo, *@arguments).call
      results.map(&:display)

      if results.length != @arguments.length
        @arguments = @arguments - results.map(&:name)

        raise NoResults.new(@arguments.first)
      end

    rescue NoResults
      @arguments.each do |missing|
        $stderr.puts "error: package '#{missing}' was not found"
      end

      exit @arguments.length
    end
  end
end
