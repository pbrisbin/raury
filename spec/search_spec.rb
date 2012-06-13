require 'spec_helper'

describe Raury::Search do
  it "executes search" do
    s = Raury::Search.new(['aur', 'helper'])

    result = double("result")
    result.should_receive(:display)

    rpc = double("rpc")
    rpc.should_receive(:call).and_return([result])

    Raury::Rpc.should_receive(:new).with(:search, 'aur', 'helper').and_return(rpc)

    s.search
  end

  it "exits on no search results" do
    s = Raury::Search.new(['aur', 'helper'])

    rpc = double("rpc")
    rpc.should_receive(:call).and_raise(Raury::NoResults.new('aur'))

    Raury::Rpc.should_receive(:new).with(:search, 'aur', 'helper').and_return(rpc)

    exited = false

    begin s.search
    rescue SystemExit
      exited = true
    end

    exited.should be_true
  end

  it "executes info" do
    s = Raury::Search.new(['aurget'])

    result = double("result")
    result.should_receive(:display)

    rpc = double("rpc")
    rpc.should_receive(:call).and_return([result])

    Raury::Rpc.should_receive(:new).with(:multiinfo, 'aurget').and_return(rpc)

    s.info
  end

  it "errors on no info results" do
    s = Raury::Search.new(['aurget'])

    rpc = double("rpc")
    rpc.should_receive(:call).and_return([])

    Raury::Rpc.should_receive(:new).with(:multiinfo, 'aurget').and_return(rpc)

    begin
      s.should_receive(:error)
      s.info
    rescue SystemExit
    end
  end
end
