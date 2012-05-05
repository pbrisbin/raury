require 'cgi'

module Raury
  # A search rpc call: Search.new(['aur', 'helper'])
  class Search < Rpc
    def type
      'search'
    end

    def to_query(search_terms)
      "&arg=#{CGI::escape(search_terms.join(' '))}"
    end

    def output_method
      :search
    end
  end
end
