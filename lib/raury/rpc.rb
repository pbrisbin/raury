require 'json'

module Raury
  class Rpc
    def initialize(args)
      @rpc = Aur.new("/rpc.php?type=#{type}#{to_query(args)}")
    end

    def call
      results = JSON.parse(@rpc.fetch)['results']

      raise NoResults unless results.is_a?(Array) && results.any?

      [].tap do |arr|
        results.each do |result|
          arr << Result.new(result)
        end
      end
    end

    def output(quiet = false)
      output = Output.new(call)
      method = quiet ? :quiet : output_method
      output.send(method)
    end

    def type
      raise SubClassNotImplemented
    end

    def to_query(args)
      raise SubClassNotImplemented
    end

    def output_method
      raise SubClassNotImplemented
    end
  end
end
