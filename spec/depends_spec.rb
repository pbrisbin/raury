require 'spec_helper'

describe Raury::Depends do
  before do
    #
    # Setup a mock dependency tree for a scenario that has various types
    # of deps we would encounter.
    #
    #   pkg
    #    |- dep1
    #    |   |- sdep1
    #    |   |- mdep2
    #    |   `- pdep1
    #    |- dep2
    #    |  `- sdep2
    #    |- pdep1
    #    |  `- sdep2
    #    `- mdep1
    #
    #            name      depends                     makedepends
    dep_tree = [['pkg',    ['dep1', 'dep2', 'pdep1'],  ['mdep1']],
                ['dep1',   ['sdep1', 'pdep1'],         ['mdep2']],
                ['dep2',   ['sdep2'],                  []       ],
                ['mdep1',  [],                         []       ],
                ['mdep2',  [],                         []       ]]

    dep_tree.each do |name, deps, mdeps|
      Raury::Aur.responses["/packages/#{name.slice(0,2)}/#{name}/PKGBUILD"] = %[
        name=#{name}
        depends=( #{deps.join(' ')} )
        makedepends=( #{mdeps.join(' ')} )

        build() {
          true
        }
      ]
    end

    Raury::Aur.responses['/packages/pd/pdep1/PKGBUILD'] = lambda do
      raise Raury::NetworkError.new('not found')
    end

    Raury::Depends.satisfieds << 'sdep1'
    Raury::Depends.satisfieds << 'sdep2'

    Raury::Depends.class_eval do
      # clear the cached value
      @checked = []
    end
  end

  it "resolves dependencies recursively" do
    plan = Raury::Plan.new.tap { |p| Raury::Depends.resolve('pkg', p) }

    # each level should be in the correct order, but the order within
    # the levels is non-deterministic. so we'll validate that the
    # motivating pkg is the last thing to be installed and that all the
    # other deps are there ahead of it.
    pkg, *rest = plan.targets.reverse

    pkg.should == 'pkg'
    rest.should match_array(['dep1', 'dep2', 'mdep1', 'mdep2'])
  end

  it "resolves correctly for build_only" do
    Raury::Config.stub(:sync_level).and_return(:build)

    plan = Raury::Plan.new.tap { |p| Raury::Depends.resolve('pkg', p) }

    plan.targets.should match_array(['pkg', 'mdep1'])
  end
end
