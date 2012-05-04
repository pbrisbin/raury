require 'raury'

describe Raury::Aur do
  it "delegates to net/http" do
    Net::HTTP.stub(:get).and_return("foo")

    aur = Raury::Aur.new("/foo")
    aur.fetch.should eq("foo")
  end
end
