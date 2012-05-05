require 'json'

module Raury
  class Rpc
    def initialize(args)
      @rpc = Aur.new("/rpc.php?type=#{type}#{to_query(args)}")
    end

    def call
      results = JSON.parse(@rpc.fetch)['results']

      [].tap do |arr|
        results.each do |result|
          arr << Result.new(result)
        end
      end

    rescue NetworkError => ex
      raise ex
    rescue Exception
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
