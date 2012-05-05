require 'cgi'

module Raury
  class Info < Rpc
    def type
      'multiinfo'
    end

    def to_query(pkgs)
      pkgs.map { |pkg| "&arg[]=#{CGI::escape(pkg)}" }.join
    end

    def output_method
      :info
    end
  end
end
