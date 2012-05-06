require 'raury'

describe Raury::Download do
  it "should download a taurball" do
    result = double("result", :pkg_url => '/a/url.tar.gz')

    Raury::Rpc.any_instance.stub(:call).and_return(result)
    Raury::Aur.any_instance.stub(:fetch).and_return('some data')

    fh = double("fh")
    fh.should_receive(:write).with('some data')

    File.should_receive(:open).with('url.tar.gz', 'w').and_yield(fh)

    Raury::Download.new('foo').download
  end

  it "should extract directly" do
    result = double("result", :pkg_url => '/a/url')

    Raury::Rpc.any_instance.stub(:call).and_return(result)
    Raury::Aur.any_instance.stub(:fetch).and_return('some data')

    h = double("h")
    h.should_receive(:write).with('some data')
    h.should_receive(:close_write)

    IO.should_receive(:popen).with('tar fxz -', 'w').and_yield(h)

    Raury::Download.new('foo').extract
  end
end
