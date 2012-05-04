require 'json'
require 'uri'
require 'net/http'

module Raury
  class Json
    def initialize(url)
      @uri = URI.parse(url)
    end

    def content
      unless @json
        resp = Net::HTTP.get(@uri)
        @json = JSON.parse(resp)
      end

      @json

    rescue Exception => ex
      Logger.debug "Json#content: #{ex}"
      raise NetworkException
    end
  end
end
