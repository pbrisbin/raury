require 'spec_helper'

module Raury
  describe Plan do
    before do
      Plan.any_instance.stub(:puts)
      @it = Plan.new(['bar', 'foo'])
    end

    it "takes constructor args" do
      @it.targets.should == ['foo', 'bar']
    end

    it "won't duplicate" do
      @it.add_target('foo')
      @it.add_target('fab')
      @it.add_target('foo')
      @it.targets.should == ['fab', 'foo','bar']
    end

    it "skips ignores" do
      Config.stub(:ignore?).and_return(true)

      @it.stub(:prompt).and_return(false) # mimic user says no!
      @it.should_receive(:warn) # warn about skipping

      @it.add_target('something')
    end

    it "resolves dependencies" do
      @it = Plan.new(['foo'])

      Depends.should_receive(:resolve).with('foo', @it)
      @it.resolve_dependencies!
    end

    it "fetches results" do
      results  = [Result.new(:multiinfo, {"Name" => 'bar'}), Result.new(:multiinfo, {"Name" => 'foo'})]
      callable = double("results", :call => results)
      Rpc.should_receive(:new).with(:multiinfo, 'foo', 'bar').and_return(callable)

      @it.fetch_results!
    end

    it "raises no results" do
      results  = []
      callable = double("results", :call => results)
      Rpc.should_receive(:new).with(:multiinfo, 'foo', 'bar').and_return(callable)

      lambda { @it.fetch_results! }.should raise_error(NoResults)
    end

    it "should raise on no targets" do
      @it.stub(:targets).and_return([])

      lambda { @it.fetch_results! }.should raise_error(NoTargets)
    end

    it "should download when downloading" do
      Config.stub(:download?).and_return(true)
      Config.stub(:build?).and_return(false)

      result = double("result", :name => 'foo')

      @it.stub(:prompt).and_return(true)
      @it.stub(:results).and_return([result])

      instance = double("download")
      instance.should_receive(:download)

      Download.should_receive(:new).with(result).and_return(instance)
      Build.should_not_receive(:new)

      @it.run!
    end

    it "should build when building" do
      Config.stub(:download?).and_return(false)
      Config.stub(:build?).and_return(true)

      result = double("result", :name => 'foo')

      @it.stub(:prompt).and_return(true)
      @it.stub(:results).and_return([result])

      instance = double("download")
      instance.should_receive(:extract)

      binstance = double("build")
      binstance.should_receive(:build)

      Download.should_receive(:new).with(result).and_return(instance)
      Build.should_receive(:new).with('foo').and_return(binstance)

      @it.run!
    end

    it "should report nothing to do when no updates are found" do
      Upgrades.stub(:pacman_Qm).and_return([])

      p = Plan.new
      Upgrades.add_to(p)

      p.should_receive(:puts).with("there is nothing to do")

      begin
        p.run!
      rescue SystemExit
      end
    end

    it "should sync correctly" do
      @it.should_receive(:resolve_dependencies!)
      @it.should_receive(:fetch_results!)
      @it.should_receive(:run!)

      @it.sync
    end

    it "should upgrade correctly with no targets" do
      @it.stub(:targets).and_return([])

      @it.should_receive(:run!)
      Upgrades.should_receive(:add_to).with(@it)

      @it.upgrade
    end

    it "should upgrade correctly with targets" do
      @it.stub(:targets).and_return(['foo', 'bar'])

      @it.should_receive(:resolve_dependencies!)
      @it.should_receive(:fetch_results!)
      @it.should_receive(:run!)
      Upgrades.should_receive(:add_to).with(@it)

      @it.upgrade
    end
  end
end
