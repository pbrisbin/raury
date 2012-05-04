require 'cgi'

module Raury
  class Info < RpcCall
    def type
      'multiinfo'
    end

    def to_query(args)
      args.map { |arg| "&arg[]=#{CGI::escape(arg)}" }
    end
  end
end
