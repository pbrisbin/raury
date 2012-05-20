require 'raury'

describe Raury::Aur do
  it "delegates to Net::HTTP and uses https" do
    resp = double("resp")
    resp.stub(:body).and_return('foo')

    http = double("http")
    http.should_receive(:use_ssl=).with(true)
    http.should_receive(:request_get).with("/foo?").and_return(resp)

    Net::HTTP.should_receive(:new).with(Raury::Aur::AUR, 443).and_return(http)

    aur = Raury::Aur.new("/foo")
    aur.fetch.should eq("foo")
  end
end
