require 'spec_helper'

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

    p.targets.should == ['baz']
    p.results.map(&:name).should == ['bar']
  end

  context "when there are development packages" do
    before do
      Raury::Upgrades.stub(:pacman_Qm).and_return([['foo-git','1.0']])
    end

    it "ignores them" do
      p = Raury::Plan.new
      Raury::Upgrades.add_to(p)

      p.results.should be_empty
    end

    it "includes them if we pass --devs" do
      result = double("foo-rpc")
      result.stub(:call).and_return( # even a lower version
        Raury::Result.new(:info, {"Name" => 'foo-git', "Version" => '0.1'}))

      Raury::Rpc.stub(:new).and_return(result)

      Raury::Config.stub(:devs?).and_return(true)

      p = Raury::Plan.new
      Raury::Upgrades.add_to(p)

      p.results.map(&:name).should == ['foo-git']
    end
  end
end
