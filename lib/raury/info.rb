require 'cgi'

module Raury
  class Info < Rpc
    def type
      'multiinfo'
    end

    def to_query(*args)
      args.map { |arg| "&arg[]=#{CGI::escape(arg)}" }.join
    end
  end
end
