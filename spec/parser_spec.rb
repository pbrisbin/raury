require 'spec_helper'

module Raury
  describe Parser do
    def parser(deps_str, mdeps_str)
      Parser.new(%{
        name=whatever
        version=whatever
        depends=( #{deps_str} )
        makedepends=( #{mdeps_str} )

        build() {
          true
        }
      }.strip)
    end

    before do
      Config.stub(:source?).and_return(false)
    end

    it "should parse a simple pkgbuild" do
      deps = parser('foo bar baz', 'bat biz qui').parse!
      deps.should match_array(['foo', 'bar', 'baz', 'bat', 'biz', 'qui'])
    end

    it "should handle mixed quoting and spacing" do
      deps = parser("foo 'bar'    baz", '  bat "biz" qui').parse!
      deps.should match_array(['foo', 'bar', 'baz', 'bat', 'biz', 'qui'])
    end

    it "should handle newlines" do
      deps = parser("foo \n'bar' baz", "\n  " + 'bat "biz" qui').parse!
      deps.should match_array(['foo', 'bar', 'baz', 'bat', 'biz', 'qui'])
    end

    it "should handle comments" do
      deps = parser("foo \n# a comment\n  'bar' # a comment\nbaz", "\n  " + 'bat "biz" qui').parse!
      deps.should match_array(['foo', 'bar', 'baz', 'bat', 'biz', 'qui'])
    end

    it "should handle empty/nonexistent" do
      deps = Parser.new(%{
        name=whatever
        version=whatever
        makedepends=( )

        build() {
          true
        }
      }.strip).parse!
      deps.should be_empty
    end

    it "should respect build_only" do
      Config.stub(:sync_level).and_return(:build)

      deps = parser('foo bar baz', 'bat biz qui').parse!
      deps.should match_array(['bat', 'biz', 'qui'])
    end

    it "sources via bash" do
      Config.stub(:source?).and_return(true)

      handle = double('io-handle')

      # we're going to dump the PKGBUILD into bash somehow and then try
      # to read back the deps. by not being super specific we allow the
      # implemention to change without having to fiddle with tests.
      handle.stub(:puts)
      handle.stub(:write)
      handle.stub(:close_write)

      # this is all that really matters.
      handle.should_receive(:read).and_return("one\ntwo\n")
      IO.should_receive(:popen).with('bash', 'r+').and_yield(handle)

      deps = Parser.new(nil).parse!
      deps.should == ['one', 'two']
    end
  end
end
