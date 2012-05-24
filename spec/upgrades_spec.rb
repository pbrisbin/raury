require 'raury'

describe Raury::Upgrades do
  it "finds available upgrades" do
    Raury::Upgrades.stub(:pacman_Qm).and_return([['foo','1.0'],['bar','2.0']])

    # foo is up to date
    foo_result = double("foo-rpc")
    foo_result.should_receive(:call).and_return(
      Raury::Result.new(:info, {"Name" => 'foo', "Version" => '1.0'}))

    # bar has an update available
    bar_result = double("bar-rpc")
    bar_result.should_receive(:call).and_return(
      Raury::Result.new(:info, {"Name" => 'bar', "Version" => '2.1'}))

    Raury::Rpc.should_receive(:new).with(:info, 'foo').and_return(foo_result)
    Raury::Rpc.should_receive(:new).with(:info, 'bar').and_return(bar_result)

    p = Raury::Plan.new(['baz'])
    Raury::Upgrades.add_to(p)

    p.targets.should eq(['baz'])
    p.results.map(&:name).should eq(['bar'])
  end

  it "ignores development packages" do
    Raury::Upgrades.stub(:pacman_Qm).and_return([['foo-git','1.0']])

    p = Raury::Plan.new
    Raury::Upgrades.add_to(p)

    p.results.should eq([])
  end
end
