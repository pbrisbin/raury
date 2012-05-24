require 'raury'

describe Raury::BuildPlan do
  it "takes constructor args" do
    bp = Raury::BuildPlan.new(['foo', 'bar'])
    bp.targets.should eq(['foo', 'bar'])
  end

  it "won't duplicate" do
    bp = Raury::BuildPlan.new

    bp.add_target('foo')
    bp.add_target('fab')
    bp.add_target('foo')
    bp.targets.should eq(['foo','fab'])
  end
end
