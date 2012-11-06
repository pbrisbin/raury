require 'spec_helper'

module Raury
  describe Rpc, '#new' do
    it "raises invalid usage on bad search type" do
      lambda { Rpc.new(:foo) }.should raise_error(InvalidUsage)
    end

    it "concatenates and escapes search terms" do
      Aur.should_receive(:new).with('/rpc.php?type=search&arg=aur+helper')
      Rpc.new(:search, 'aur', 'helper')
    end

    it "sets for info with one arg" do
      Aur.should_receive(:new).with('/rpc.php?type=info&arg=first')
      Rpc.new(:info, 'first', 'second')
    end

    it "sets for multiinfo with all args" do
      Aur.should_receive(:new).with('/rpc.php?type=multiinfo&arg[]=foo+bar&arg[]=bat')
      Rpc.new(:multiinfo, 'foo bar', 'bat')
    end
  end

  describe Rpc, '#call' do
    it "handles no results based on type" do
      sample_json = '{"type":"error","results":"Some error..."}'
      Aur.any_instance.stub(:fetch).and_return(sample_json)

      lambda { Rpc.new(:search, 'foo').call }.should raise_error(NoResults)
    end

    it "handles no results based on count" do
      sample_json = '{"type":"search","resultcount":0,"results":[]}'
      Aur.any_instance.stub(:fetch).and_return(sample_json)

      lambda { Rpc.new(:search, 'foo').call }.should raise_error(NoResults)
    end

    it "builds results" do
      sample_json = '{"type":"search","resultcount":2,"results":[{"Name":"foo"},{"Name":"bar"}]}'

      Aur.any_instance.stub(:fetch).and_return(sample_json)

      rpc = Rpc.new(:search, 'foo')
      results = rpc.call

      results.length.should == 2

      result = results.first

      result.should be_kind_of(Result)
      result.type.should == :search
      result.name.should == 'foo'
    end

    it "returns one result for info" do
      sample_json = '{"type":"info","resultcount":1,"results":{"Name":"foo"}}'

      Aur.any_instance.stub(:fetch).and_return(sample_json)

      rpc = Rpc.new(:search, 'foo')
      result = rpc.call

      result.should be_kind_of(Result)
      result.type.should == :info
      result.name.should == 'foo'
    end
  end
end
