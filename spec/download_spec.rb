require 'spec_helper'

describe Raury::Download do
  it "should download a taurball" do
    Raury::Aur.any_instance.stub(:fetch).and_return('some data')

    fh = double("fh")
    fh.should_receive(:write).with('some data')

    File.should_receive(:open).with('url.tar.gz', 'w').and_yield(fh)

    result = double("result", :pkg_url => '/a/url.tar.gz')
    Raury::Download.new(result).download
  end

  it "should extract directly" do
    Raury::Aur.any_instance.stub(:fetch).and_return('some data')

    h = double("h")
    h.should_receive(:write).with('some data')
    h.should_receive(:close_write)

    IO.should_receive(:popen).with('tar fxz -', 'w').and_yield(h)

    result = double("result", :pkg_url => '/a/url')
    Raury::Download.new(result).extract
  end
end
