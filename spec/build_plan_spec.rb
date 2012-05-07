require 'raury'

describe Raury::BuildPlan do
  it "won't duplicate" do
    bp = Raury::BuildPlan.new

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

  it "can be combined" do
    bp = Raury::BuildPlan.new
    
    bp.add_target('foo')
    bp.add_incidental('bar')

    bp2 = Raury::BuildPlan.new
    bp2.add_target('foo')
    bp2.add_target('fab')
    bp2.add_incidental('baz')

    bp3 = Raury::BuildPlan.new
    bp3.add_target('flim')
    bp3.add_target('foo')
    bp3.add_incidental('bar')

    bp.combine_with(bp2, bp3)

    bp.targets.should eq(['foo','fab', 'flim'])
    bp.incidentals.should eq(['bar', 'baz'])
    bp.all.should eq(['foo', 'bar', 'fab', 'baz', 'flim'])
  end
end
