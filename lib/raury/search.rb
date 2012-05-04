require 'cgi'

module Raury
  class Search < RpcCall
    def type
      'search'
    end

    def to_query(args)
      "&arg=#{CGI::escape(args)}"
    end
  end
end
