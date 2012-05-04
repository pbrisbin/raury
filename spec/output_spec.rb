require 'raury'
require 'spec_helper'

describe Raury::Output do
  it "outputs sorted search results" do
    results = [ Raury::Result.new({ "Name"        => "beans",
                                    "Version"     => "1.0",
                                    "OutOfDate"   => "0",
                                    "Description" => "beans description" }),
                Raury::Result.new({ "Name"        => "apple",
                                    "Version"     => "2.0",
                                    "OutOfDate"   => "1",
                                    "Description" => "apple description" }) ]

    s = capture_stdout { Raury::Output.new(results).search }

    s.chomp.should eq(%{
aur/apple 2.0 [out of date]
    apple description
aur/beans 1.0
    beans description
    }.strip)
  end

  it "outputs sorted info results" do
    results = [ Raury::Result.new({ "Name"        => "beans",
                                    "Version"     => "1.0",
                                    "URL"         => "http://example.com/beans",
                                    "OutOfDate"   => "0",
                                    "Description" => "beans description" }),
                Raury::Result.new({ "Name"        => "apple",
                                    "Version"     => "2.0",
                                    "URL"         => "http://example.com/apple",
                                    "OutOfDate"   => "1",
                                    "Description" => "apple description" }) ]

    s = capture_stdout { Raury::Output.new(results).info }

    s.chomp.should eq(%{
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
end
