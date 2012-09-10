require 'spec_helper'

module Raury
  describe Upgrades do
    it "finds available upgrades" do
      Upgrades.stub(:pacman_Qm).and_return([['foo','1.0'],['bar','2.0']])

      # foo is up to date
      foo_result = double("foo-rpc")
      foo_result.should_receive(:call).and_return(
        Result.new(:info, {"Name" => 'foo', "Version" => '1.0'}))

      # bar has an update available
      bar_result = double("bar-rpc")
      bar_result.should_receive(:call).and_return(
        Result.new(:info, {"Name" => 'bar', "Version" => '2.1'}))

      Rpc.should_receive(:new).with(:info, 'foo').and_return(foo_result)
      Rpc.should_receive(:new).with(:info, 'bar').and_return(bar_result)

      p = Plan.new(['baz'])
      Upgrades.add_to(p)

      p.targets.should == ['baz']
      p.results.map(&:name).should == ['bar']
    end

    context "when there are development packages" do
      before do
        Upgrades.stub(:pacman_Qm).and_return([['foo-git','1.0']])
      end

      it "ignores them" do
        p = Plan.new
        Upgrades.add_to(p)

        p.results.should be_empty
      end

      it "includes them if we pass --devs" do
        result = double("foo-rpc")
        result.stub(:call).and_return( # even a lower version
          Result.new(:info, {"Name" => 'foo-git', "Version" => '0.1'}))

        Rpc.stub(:new).and_return(result)

        Config.stub(:devs?).and_return(true)

        p = Plan.new
        Upgrades.add_to(p)

        p.results.map(&:name).should == ['foo-git']
      end
    end
  end
end
