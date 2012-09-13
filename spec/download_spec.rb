require 'spec_helper'

module Raury
  describe Download do
    it "should download a taurball" do
      Aur.any_instance.stub(:fetch).and_return('some data')

      fh = double("fh")
      fh.should_receive(:write).with('some data')
      fh.should_receive(:close)

      File.should_receive(:open).with('url.tar.gz', 'w').and_return(fh)

      result = double("result", :pkg_url => '/a/url.tar.gz')
      Download.new(result).download
    end

    it "should extract directly" do
      Aur.any_instance.stub(:fetch).and_return('some data')

      h = double("h")
      h.should_receive(:write).with('some data')
      h.should_receive(:close)

      IO.should_receive(:popen).with('tar fxz -', 'w').and_return(h)

      result = double("result", :pkg_url => '/a/url')
      Download.new(result).extract
    end
  end
end
