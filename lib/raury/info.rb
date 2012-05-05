require 'cgi'

module Raury
  class Info < Rpc
    def type
      'multiinfo'
    end

    def to_query(pkgs)
      pkgs.map { |pkg| "&arg[]=#{CGI::escape(pkg)}" }.join
    end
  end
end
