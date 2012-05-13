require 'raury'

describe Raury::BuildPlan do
  it "takes constructor args" do
    bp = Raury::BuildPlan.new(:install, ['foo', 'bar'])
    bp.level.should eq(:install)
    bp.targets.should eq(['foo', 'bar'])
  end

  it "won't duplicate" do
    bp = Raury::BuildPlan.new(:install, [])

    bp.add_target('foo')
    bp.add_target('fab')
    bp.add_target('foo')

    bp.add_incidental('bar')
    bp.add_incidental('baz')
    bp.add_incidental('bar')

    bp.targets.should eq(['foo','fab'])
    bp.incidentals.should eq(['bar','baz'])
    bp.all.should eq(['foo', 'fab', 'bar', 'baz'])
  end
end
