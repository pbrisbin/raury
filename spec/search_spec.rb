require 'spec_helper'

module Raury
  describe Search do
    it "executes search" do
      s = Search.new(['aur', 'helper'])

      result = double("result")
      result.should_receive(:display)

      rpc = double("rpc")
      rpc.should_receive(:call).and_return([result])

      Rpc.should_receive(:new).with(:search, 'aur', 'helper').and_return(rpc)

      s.search
    end

    it "exits on no search results" do
      s = Search.new(['aur', 'helper'])

      rpc = double("rpc")
      rpc.should_receive(:call).and_raise(NoResults.new('aur'))

      Rpc.should_receive(:new).with(:search, 'aur', 'helper').and_return(rpc)

      exited = false

      begin s.search
      rescue SystemExit
        exited = true
      end

      exited.should be_true
    end

    it "executes info" do
      s = Search.new(['aurget'])

      result = double("result")
      result.should_receive(:display)

      rpc = double("rpc")
      rpc.should_receive(:call).and_return([result])

      Rpc.should_receive(:new).with(:multiinfo, 'aurget').and_return(rpc)

      s.info
    end

    it "errors on no info results" do
      s = Search.new(['aurget'])

      rpc = double("rpc")
      rpc.should_receive(:call).and_return([])

      Rpc.should_receive(:new).with(:multiinfo, 'aurget').and_return(rpc)

      begin
        s.should_receive(:error)
        s.info
      rescue SystemExit
      end
    end
  end
end
