require 'cgi'

module Raury
  # An info rpc call: Info.new(['pkg1', 'pkg2'])
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
