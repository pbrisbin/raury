require 'spec_helper'

module Raury
  describe Main do
    it "can run a search" do
      search = double("search")
      search.should_receive(:search)
      Search.should_receive(:new).with(['foo', 'bar']).and_return(search)

      Main.run!(%w[ -Ss foo bar ])
    end

    it "can run an install" do
      Dir.should_receive(:chdir).with(Config.build_directory).and_yield

      plan = double("plan")
      plan.should_receive(:sync)
      Plan.should_receive(:new).with(['foo', 'bar']).and_return(plan)

      Main.run!(%w[ -Sy foo bar ])
    end

    it "will rescue exceptions" do
      Config.stub(:debug?).and_return(true)

      Dir.stub(:chdir).and_raise("an error")

      # since debug is on
      Main.should_receive(:debug_box).twice.and_yield
      Main.should_receive(:debug).exactly(5).times

      # typical error handling flow
      Main.should_receive(:error).with("an error")
      Main.should_receive(:exit).with(1)

      Main.run!(%w[ -Sy foo bar ])
    end
  end

end
