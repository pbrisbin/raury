module Raury
  class Search
    include Output

    def initialize(*arguments)
      @arguments = arguments
    end

    def search
      debug("searching for '#{@arguments.join(' ')}'")
      results = Rpc.new(:search, *@arguments).call
      results.map(&:display)

    rescue NoResults
      debug('not results found.')
      exit 1
    end

    def info
      debug("fetching info for '#{@arguments.join(', ')}")
      results = Rpc.new(:multiinfo, *@arguments).call
      results.map(&:display)

      if results.length != @arguments.length
        @arguments = @arguments - results.map(&:name)

        debug("results were not found for '#{@arguments.join(', ')}'")
        raise NoResults.new(@arguments.first)
      end

    rescue NoResults
      @arguments.each do |missing|
        error("package '#{missing}' was not found")
      end

      exit @arguments.length
    end
  end
end
