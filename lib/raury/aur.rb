require 'uri'
require 'net/http'

module Raury
  # represents a resource available on the AUR: pkgbuilds, taurballs,
  # and rpc call results are all fetched via this class.
  class Aur
    AUR = 'aur.archlinux.org'

    def initialize(path)
      @uri = URI.parse("http://#{AUR}#{path}")
    end

    def fetch
      # TODO: handle https
      Net::HTTP.get(@uri)

    rescue Exception => ex
      raise NetworkException.new(ex)
    end
  end
end
