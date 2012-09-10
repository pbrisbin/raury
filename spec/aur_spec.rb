require 'spec_helper'

module Raury
  describe Aur do
    it "delegates to Net::HTTP and uses https" do
      resp = double("resp")
      resp.stub(:body).and_return('foo')
      resp.stub(:kind_of?).and_return(true)

      http = double("http")
      http.should_receive(:use_ssl=).with(true)
      http.should_receive(:request_get).with("/foo?").and_return(resp)

      Net::HTTP.should_receive(:new).with(Aur::AUR, 443).and_return(http)

      aur = Aur.new("/foo")
      aur.fetch.should == "foo"
    end

    it "raises network error when non-success" do
      resp = double("resp")
      resp.stub(:kind_of?).and_return(false)

      http = double("http")
      http.stub(:request_get).and_return(resp)

      Net::HTTP.stub(:new).and_return(http)

      lambda { Aur.new("/").fetch }.should raise_error(NetworkError)
    end
  end
end
