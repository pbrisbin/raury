require 'spec_helper'

describe Raury::Plan do
  before do
    Raury::Plan.any_instance.stub(:puts)
    @it = Raury::Plan.new(['bar', 'foo'])
  end

  it "takes constructor args" do
    @it.targets.should eq(['foo', 'bar'])
  end

  it "won't duplicate" do
    @it.add_target('foo')
    @it.add_target('fab')
    @it.add_target('foo')
    @it.targets.should eq(['fab', 'foo','bar'])
  end

  it "skips ignores" do
    Raury::Config.stub(:ignore?).and_return(true)

    @it.stub(:prompt).and_return(false) # mimic user says no!
    @it.should_receive(:warn) # warn about skipping

    @it.add_target('something')
  end

  it "resolves dependencies" do
    @it = Raury::Plan.new(['foo'])

    Raury::Depends.should_receive(:resolve).with('foo', @it)
    @it.resolve_dependencies!
  end

  it "fetches results" do
    results  = [Raury::Result.new(:multiinfo, {"Name" => 'bar'}), Raury::Result.new(:multiinfo, {"Name" => 'foo'})]
    callable = double("results", :call => results)
    Raury::Rpc.should_receive(:new).with(:multiinfo, 'foo', 'bar').and_return(callable)

    @it.fetch_results!
  end

  it "raises no results" do
    results  = []
    callable = double("results", :call => results)
    Raury::Rpc.should_receive(:new).with(:multiinfo, 'foo', 'bar').and_return(callable)

    lambda { @it.fetch_results! }.should raise_error(Raury::NoResults)
  end

  it "should raise on no targets" do
    @it.stub(:targets).and_return([])

    lambda { @it.fetch_results! }.should raise_error(Raury::NoTargets)
  end

  it "should download when downloading" do
    Raury::Config.stub(:download?).and_return(true)
    Raury::Config.stub(:build?).and_return(false)

    result = double("result", :name => 'foo')

    @it.stub(:prompt).and_return(true)
    @it.stub(:results).and_return([result])

    instance = double("download")
    instance.should_receive(:download)

    Raury::Download.should_receive(:new).with(result).and_return(instance)
    Raury::Build.should_not_receive(:new)

    @it.run!
  end

  it "should build when building" do
    Raury::Config.stub(:download?).and_return(false)
    Raury::Config.stub(:build?).and_return(true)

    result = double("result", :name => 'foo')

    @it.stub(:prompt).and_return(true)
    @it.stub(:results).and_return([result])

    instance = double("download")
    instance.should_receive(:extract)

    binstance = double("build")
    binstance.should_receive(:build)

    Raury::Download.should_receive(:new).with(result).and_return(instance)
    Raury::Build.should_receive(:new).with('foo').and_return(binstance)

    @it.run!
  end

  it "should report nothing to do when no updates are found" do
    Raury::Upgrades.stub(:pacman_Qm).and_return([])

    p = Raury::Plan.new
    Raury::Upgrades.add_to(p)

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
    Raury::Upgrades.should_receive(:add_to).with(@it)

    @it.upgrade
  end

  it "should upgrade correctly with targets" do
    @it.stub(:targets).and_return(['foo', 'bar'])

    @it.should_receive(:resolve_dependencies!)
    @it.should_receive(:fetch_results!)
    @it.should_receive(:run!)
    Raury::Upgrades.should_receive(:add_to).with(@it)

    @it.upgrade
  end
end
