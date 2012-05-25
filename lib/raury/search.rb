module Raury
  class Search
    include Output

    def initialize(*arguments)
      @arguments = arguments
    end

    def search
      debug("calling search for '#{@arguments.join(' ')}'")
      results = Rpc.new(:search, *@arguments).call
      results.map(&:display)

    rescue NoResults
      debug('not results found.')
      exit 1
    end

    def info
      debug("calling multiinfo for #{@arguments}")
      results = Rpc.new(:multiinfo, *@arguments).call
      results.map(&:display)

      if results.length != @arguments.length
        @arguments = @arguments - results.map(&:name)
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
