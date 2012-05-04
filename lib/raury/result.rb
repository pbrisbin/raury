module Raury
  # wrapper class over the hash values returned by aur's rpc calls.
  # provides better accessor methods and type conversions where
  # appropriate.
  #
  #     result = Result.new({"Name" => "foo", "OutOfDate" => "1"})
  #
  #     result.name
  #     => "foo"
  #
  #     result.out_of_date
  #     => true
  #
  class Result
    # define an instance method called +method+, which accesses the
    # internal json hash by +key+. if +conversion+ is not nil, it's
    # called on the value before returning it.
    def self.def_accessor(method, key, conversion = nil)
      conversions[method] = conversion

      self.class_eval %{
        def #{method}
          value = @hsh['#{key}'] # may be nil
          conv  = self.class.conversions[#{method.inspect}]

          (value && conv) ? conv.call(value) : value
        end
      }
    end

    # stores any defined conversion functions for use later.
    def self.conversions
      @conversions ||= {}
    end

    def_accessor :description, "Description"
    def_accessor :license    , "License"
    def_accessor :maintainer , "Maintainer"
    def_accessor :name       , "Name"
    def_accessor :pkg_url    , "URLPath"
    def_accessor :url        , "URL"
    def_accessor :version    , "Version"
    def_accessor :pkg_id     , "ID"            , lambda {|s| s.to_i}
    def_accessor :category   , "CategoryID"    , lambda {|s| s.to_i}
    def_accessor :votes      , "NumVotes"      , lambda {|s| s.to_i}
    def_accessor :out_of_date, "OutOfDate"     , lambda {|s| s == '1' }
    def_accessor :submitted  , "FirstSubmitted", lambda {|s| Time.at(s.to_i) }
    def_accessor :modified   , "LastModified"  , lambda {|s| Time.at(s.to_i) }

    def initialize(hsh)
      @hsh = hsh
    end
  end
end
