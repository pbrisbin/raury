module Raury
  class RpcCall
    AUR = 'aur.archlinux.org'

    def initialize(*args)
      @query = "?type=#{type}#{to_query(*args)}"
    end

    def call
      # TODO: make https work.
      results = Json.new("http://#{AUR}/rpc.php#{@query}").content['results']

      [].tap do |arr|
        results.each do |result|
          arr << SearchResult.new(result)
        end
      end

    rescue NetworkError => ex
      raise ex
    rescue Exception => ex
      Logger.debug "RpcCall#call! #{ex}"
      raise NoResults
    end

    def type
      raise SubClassNotImplemented
    end

    def to_query(args)
      raise SubClassNotImplemented
    end
  end
end
