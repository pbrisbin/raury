require 'raury'

module Raury
  class Depends
    def self.pacman_T(deps)
      deps - satisfieds
    end

    def self.satisfieds
      @satisfieds ||= []
    end
  end
end

module Raury
  class Aur
    def initialize(path)
      @path = path
    end

    def fetch
      self.class.responses[@path]
    end

    def self.responses
      @responses ||= {}
    end
  end
end

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

    Raury::Aur.responses['/packages/pd/pdep1/PKGBUILD'] = "Not found"

    Raury::Depends.satisfieds << 'sdep1'
    Raury::Depends.satisfieds << 'sdep2'
  end

  it "resolves dependencies recursively" do
    bp = Raury::BuildPlan.new.tap { |bp| Raury::Depends.resolve('pkg', bp) }

    bp.incidentals.should eq(['pdep1'])

    # each level should be in the correct (reverse-install) order, but
    # the order within the levels is non-deterministic.
    targets = bp.targets.uniq.reverse

    # so we'll validate that the motivating pkg is the last thing to be
    # installed and that all the other deps are there ahead of it.
    targets.pop.should  eq('pkg')
    targets.sort.should eq(['dep1', 'dep2', 'mdep1', 'mdep2'].sort)
  end

  it "resolves correctly for build_only" do
    Raury::Config.stub(:sync_level).and_return(:build)

    bp = Raury::BuildPlan.new.tap { |bp| Raury::Depends.resolve('pkg', bp) }

    bp.incidentals.should eq([])
    bp.targets.uniq.sort.should eq(['pkg', 'mdep1'].sort)
  end
end
