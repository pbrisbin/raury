require 'cgi'
require 'json'

module Raury
  # Wrapper over Aur which calls the rpc resource. 
  class Rpc
    def initialize(type, *args)
      args_str = case type
                 when :search    then to_arg(args.join(' '))
                 when :info      then to_arg(args.first)
                 when :multiinfo then to_args(args)
                 else raise InvalidUsage
                 end

      @args = args # for error message
      @rpc  = Aur.new("/rpc.php?type=#{type}#{args_str}")
    end

    # fetch and parse the resource as JSON, return the values wrapped in
    # a Result instance.
    def call
      json = JSON.parse(@rpc.fetch)
      type = json['type']

      unless results?(json)
        raise NoResults.new(@args.first)
      end

      if type == 'info'
        Result.new(type.to_sym, json['results'])
      else
        json['results'].map do |result|
          Result.new(type.to_sym, result)
        end
      end
    end

    def to_arg(arg)
      "&arg=#{CGI::escape(arg)}"
    end

    def to_args(args)
      args.map { |arg| "&arg[]=#{CGI::escape(arg)}" }.join
    end

    private

    def results?(json)
      count = json['resultcount']
      count && count != 0 && valid_type?(json)
    end

    def valid_type?(json)
      ['info', 'search', 'multiinfo'].include?(json['type'])
    end
  end
end
