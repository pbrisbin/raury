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

      @rpc = Aur.new("/rpc.php?type=#{type}#{args_str}")
    end

    def call
      json = JSON.parse(@rpc.fetch)
      type = json['type']

      if type == 'info'
        return Result.new(json['results'])
      end

      if ['search','multiinfo'].include?(type)
        return [].tap do |arr|
          json['results'].each do |result|
            arr << Result.new(result)
          end
        end
      end

      raise NoResults
    end

    def to_arg(arg)
      "&arg=#{CGI::escape(arg)}"
    end

    def to_args(args)
      args.map { |arg| "&arg[]=#{CGI::escape(arg)}" }.join
    end
  end
end
