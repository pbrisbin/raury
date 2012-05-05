require 'json'

module Raury
  # a layer over Aur to represent a specific rpc resource. this should
  # be subclassed and the noted methods implemented.
  class Rpc
    def initialize(args)
      @rpc = Aur.new("/rpc.php?type=#{type}#{to_query(args)}")
    end

    # fetch the rpc resource and return a list of Result
    def call
      results = JSON.parse(@rpc.fetch)['results']

      raise NoResults unless results.is_a?(Array) && results.any?

      [].tap do |arr|
        results.each do |result|
          arr << Result.new(result)
        end
      end
    end

    # fetch the rpc resource, passing the list of Result to an Output
    # and call the output_method on it. if +quiet+ is true, run the
    # quiet method on the output instead.
    def output(quiet = false)
      output = Output.new(call)
      method = quiet ? :quiet : output_method
      output.send(method)
    end

    # the type query param. examples: 'search', 'info', 'multiinfo'
    def type
      raise SubClassNotImplemented
    end

    # format an array of arguments into the argument query param(s).
    # examples: "&arg=foo", "&arg[]=foo+bar&arg[]=baz"
    def to_query(args)
      raise SubClassNotImplemented
    end

    # the output method to use. examples: :search, :info
    def output_method
      raise SubClassNotImplemented
    end
  end
end
