require 'raury'
require 'spec_helper'

describe Raury::Output do
  it "outputs sorted search results" do
    results = [ Raury::SearchResult.new({ "Name"        => "beans",
                                          "Version"     => "1.0",
                                          "OutOfDate"   => "0",
                                          "Description" => "beans description" }),
                Raury::SearchResult.new({ "Name"        => "apple",
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
end
