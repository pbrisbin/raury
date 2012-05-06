require 'raury'

describe Raury::Rpc, '#new' do
  it "raises invalid usage on bad search type" do
    lambda { Raury::Rpc.new(:foo) }.should raise_error(Raury::InvalidUsage)
  end

  it "concatenates and escapes search terms" do
    Raury::Aur.should_receive(:new).with('/rpc.php?type=search&arg=aur+helper')
    Raury::Rpc.new(:search, 'aur', 'helper')
  end

  it "sets for info with one arg" do
    Raury::Aur.should_receive(:new).with('/rpc.php?type=info&arg=first')
    Raury::Rpc.new(:info, 'first', 'second')
  end

  it "sets for multiinfo with all args" do
    Raury::Aur.should_receive(:new).with('/rpc.php?type=multiinfo&arg[]=foo+bar&arg[]=bat')
    Raury::Rpc.new(:multiinfo, 'foo bar', 'bat')
  end
end

describe Raury::Rpc, '#call' do
  it "handles no results" do
    sample_json = '{"type":"error","results":"No results..."}'
    Raury::Aur.any_instance.stub(:fetch).and_return(sample_json)

    lambda { Raury::Rpc.new(:search, 'foo').call }.should raise_error(Raury::NoResults)
  end

  it "builds results" do
    sample_json = '{"type":"search","results":[{"Name":"foo"},{"Name":"bar"}]}'

    Raury::Aur.any_instance.stub(:fetch).and_return(sample_json)

    rpc = Raury::Rpc.new(:search, 'foo')
    results = rpc.call

    results.length.should eql(2)

    result = results.first

    result.should be_kind_of(Raury::Result)
    result.name.should eq('foo')
  end

  it "returns one result for info" do
    sample_json = '{"type":"info","results":{"Name":"foo"}}'

    Raury::Aur.any_instance.stub(:fetch).and_return(sample_json)

    rpc = Raury::Rpc.new(:search, 'foo')
    result = rpc.call

    result.should be_kind_of(Raury::Result)
    result.name.should eq('foo')
  end
end
