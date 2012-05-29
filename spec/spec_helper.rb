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
end

module Raury
  class Aur
    alias_method :original_fetch, :fetch
    alias_method :original_initialize, :initialize

    def initialize(path)
      @path = path

      original_initialize(path)
    end

    def fetch
      self.class.responses[@path] || original_fetch
    end

    # add values to this array by relative path, they will be returned
    # before falling back the original fetch method.
    def self.responses
      @responses ||= {}
    end
  end
end
