require 'raury'
require 'spec_helper'

describe Raury::Output do
  context "results" do
    results = [ Raury::Result.new({ "Name"        => "beans",
                                    "Version"     => "1.0",
                                    "URL"         => "http://example.com/beans",
                                    "URLPath"     => "packages/be/beands/beans.tar.gz",
                                    "OutOfDate"   => "0",
                                    "Description" => "beans description" }),
                Raury::Result.new({ "Name"        => "apple",
                                    "Version"     => "2.0",
                                    "URL"         => "http://example.com/apple",
                                    "URLPath"     => "packages/ap/apple/apple.tar.gz",
                                    "OutOfDate"   => "1",
                                    "Description" => "apple description" }) ]

    output = Raury::Output.new(results)

    it "outputs sorted search" do
      capture_stdout { output.search }.chomp.should eq(%{
aur/apple 2.0 [out of date]
    apple description
aur/beans 1.0
    beans description
      }.strip)
    end

    it "outputs sorted info" do
      capture_stdout { output.info }.chomp.should eq(%{
Repository      : aur
Name            : apple
Version         : 2.0
URL             : http://example.com/apple
Out of date     : Yes
Description     : apple description

Repository      : aur
Name            : beans
Version         : 1.0
URL             : http://example.com/beans
Out of date     : No
Description     : beans description
      }.strip + "\n") # trailing newline
    end

    it "outputs sorted quiet" do
      capture_stdout { output.quiet }.chomp.should eq(%{
apple
beans
      }.strip)
    end

    it "outputs pkgbuild do" do
      pkgbuild = %{
I am a PKGBUILD
I should have lots of crap here
      }.strip

      Raury::Aur.any_instance.stub(:fetch).and_return(pkgbuild)
      capture_stdout { output.pkgbuild }.chomp.should eq("#{pkgbuild}\n\n#{pkgbuild}\n")
    end
  end
end
