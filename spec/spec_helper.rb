require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end

require 'raury'

module Raury
  class Depends
    # mock a pacman_T such that we can control what's satisfied and
    # what's not by adding the satisfieds array, by default nothing is
    # satisfied.
    def self.pacman_T(deps)
      deps - satisfieds
    end

    def self.satisfieds
      @satisfieds ||= []
    end
  end

  class Aur
    alias_method :original_fetch, :fetch

    # return hardcoded responses. if response is a lambda, call it
    # (allows simulating exceptions); otherwise, return it. falls back
    # to original_fetch if no response is hardcoded.
    def fetch
      if r = self.class.responses[@uri.path]
        return r.respond_to?(:call) ? r.call : r
      end

      original_fetch
    end

    # hardcode response by adding to this hash, keyed by path.
    def self.responses
      @responses ||= {}
    end
  end
end
