require 'spec_helper'

describe Raury::Parser do
  def parser(deps_str, mdeps_str)
    Raury::Parser.new(%{
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
    Raury::Config.stub(:source?).and_return(false)
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
    deps = Raury::Parser.new(%{
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
    Raury::Config.stub(:sync_level).and_return(:build)

    deps = parser('foo bar baz', 'bat biz qui').parse!
    deps.should match_array(['bat', 'biz', 'qui'])
  end
end
