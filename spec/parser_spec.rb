require 'spec_helper'

describe Raury::Parser do
  def build_pkgbuild(deps_str, mdeps_str)
    %{
name=whatever
version=whatever
depends=( #{deps_str} )
makedepends=( #{mdeps_str} )

build() {
  true
}
    }.strip
  end

  it "should parse a simple pkgbuild" do
    pkgbuild = build_pkgbuild('foo bar baz', 'bat biz qui')

    deps = Raury::Parser.parse!(pkgbuild)
    deps.should match_array(['foo', 'bar', 'baz', 'bat', 'biz', 'qui'])
  end

  it "should handle mixed quoting and spacing" do
    pkgbuild = build_pkgbuild("foo 'bar'    baz", '  bat "biz" qui')

    deps = Raury::Parser.parse!(pkgbuild)
    deps.should match_array(['foo', 'bar', 'baz', 'bat', 'biz', 'qui'])
  end

  it "should handle newlines" do
    pkgbuild = build_pkgbuild("foo \n'bar' baz", "\n  " + 'bat "biz" qui')

    deps = Raury::Parser.parse!(pkgbuild)
    deps.should match_array(['foo', 'bar', 'baz', 'bat', 'biz', 'qui'])
  end

  it "should handle comments" do
    pkgbuild = build_pkgbuild("foo \n# a comment\n  'bar' # a comment\nbaz", "\n  " + 'bat "biz" qui')

    deps = Raury::Parser.parse!(pkgbuild)
    deps.should match_array(['foo', 'bar', 'baz', 'bat', 'biz', 'qui'])
  end

  it "should handle empty/nonexistent" do
    pkgbuild = %{
name=whatever
version=whatever
makedepends=( )

build() {
  true
}
    }.strip

    deps = Raury::Parser.parse!(pkgbuild)
    deps.should be_empty
  end

  it "should respect build_only" do
    pkgbuild = build_pkgbuild('foo bar baz', 'bat biz qui')

    deps = Raury::Parser.parse!(pkgbuild, true)
    deps.should match_array(['bat', 'biz', 'qui'])
  end
end
