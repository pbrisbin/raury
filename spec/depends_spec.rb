require 'spec_helper'

module Raury
  describe Depends do
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
        Aur.responses["/packages/#{name.slice(0,2)}/#{name}/PKGBUILD"] = %[
          name=#{name}
          depends=( #{deps.join(' ')} )
          makedepends=( #{mdeps.join(' ')} )

          build() {
            true
          }
        ]
      end

      Aur.responses['/packages/pd/pdep1/PKGBUILD'] = lambda do
        raise NetworkError.new('not found')
      end

      Depends.satisfieds << 'sdep1'
      Depends.satisfieds << 'sdep2'

      Depends.class_eval do
        # clear the cached value
        @checked = []
      end
    end

    it "resolves dependencies recursively" do
      plan = Plan.new.tap { |p| Depends.resolve('pkg', p) }

      # each level should be in the correct order, but the order within
      # the levels is non-deterministic. so we'll validate that the
      # motivating pkg is the last thing to be installed and that all the
      # other deps are there ahead of it.
      pkg, *rest = plan.targets.reverse

      pkg.should == 'pkg'
      rest.should match_array(['dep1', 'dep2', 'mdep1', 'mdep2'])
    end

    it "resolves correctly for build_only" do
      Config.stub(:sync_level).and_return(:build)

      plan = Plan.new.tap { |p| Depends.resolve('pkg', p) }

      plan.targets.should match_array(['pkg', 'mdep1'])
    end
  end
end
