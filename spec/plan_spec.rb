require 'raury'

describe Raury::Plan do
  before do
    Raury::Plan.any_instance.stub(:puts)
    @it = Raury::Plan.new(['foo', 'bar'])
  end

  it "takes constructor args" do
    @it.targets.should eq(['foo', 'bar'])
  end

  it "won't duplicate" do
    @it.add_target('foo')
    @it.add_target('fab')
    @it.add_target('foo')
    @it.targets.should eq(['foo','bar','fab'])
  end

  it "resolves dependencies" do
    @it = Raury::Plan.new(['foo'])

    Raury::Depends.should_receive(:resolve).with('foo', @it)
    @it.resolve_dependencies!
  end

  it "fetches results" do
    results  = [Raury::Result.new(:multiinfo, {})]*2
    callable = double("results", :call => results)
    Raury::Rpc.should_receive(:new).with(:multiinfo, *['bar','foo']).and_return(callable)

    @it.fetch_results!
  end

  it "raises no results" do
    results  = []
    callable = double("results", :call => results)
    Raury::Rpc.should_receive(:new).with(:multiinfo, *['bar','foo']).and_return(callable)

    lambda { @it.fetch_results! }.should raise_error(Raury::NoResults)
  end

  it "should raise on no targets" do
    @it.stub(:results).and_return([])

    lambda { @it.run! }.should raise_error(Raury::NoTargets)
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
end
