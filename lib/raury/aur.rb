require 'uri'
require 'net/https'

module Raury
  # represents a resource available on the AUR: pkgbuilds, taurballs,
  # and rpc call results are all fetched via this class.
  class Aur
    AUR = 'aur.archlinux.org'

    def initialize(path)
      @uri = URI.parse("https://#{AUR}#{path}")
    end

    def fetch
      http = Net::HTTP.new(@uri.host, 443)
      http.use_ssl = true
      resp = http.request_get("#{@uri.path}?#{@uri.query}")

      unless resp.kind_of?(Net::HTTPSuccess)
        raise "response not successfull: #{resp.code}"
      end

      resp.body

    rescue Exception => ex
      raise NetworkError.new(ex)
    end
  end
end
