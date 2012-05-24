require 'raury'

describe Raury::Plan do
  it "takes constructor args" do
    bp = Raury::Plan.new(['foo', 'bar'])
    bp.targets.should eq(['foo', 'bar'])
  end

  it "won't duplicate" do
    bp = Raury::Plan.new

    bp.add_target('foo')
    bp.add_target('fab')
    bp.add_target('foo')
    bp.targets.should eq(['foo','fab'])
  end
end
