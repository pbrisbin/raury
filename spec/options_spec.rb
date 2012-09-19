require 'spec_helper'

module Raury
  describe Options do
    it "raises invalid usage on bad options" do
      lambda {

        Options.parse!(%w[ --foo -blam -o -blat ])

      }.should raise_error(InvalidUsage)
    end

    it "handles common commands correctly" do
      command, arguments = Options.parse! %w[ -S aurget ]

      command.should == :sync
      arguments.should == ['aurget']

      command, arguments = Options.parse! %w[ -Syu ]

      command.should == :upgrade
      arguments.should be_empty
      Config.sync_level.should == :install

      command, arguments = Options.parse! %w[ -Ss aur helper ]

      command.should == :search
      arguments.should == ['aur', 'helper']

      command, arguments = Options.parse! %w[ -Ssi aurget ]

      command.should == :info
      arguments.should == ['aurget']
    end

    # not really a test context, just needs a before/after to allow the
    # config to be mutated during this spec only.
    context do
      before do
        Config.mutable = true
      end

      after do
        Config.mutable = false
      end

      it "handles options correctly" do
        [ [ '-d',             :sync_level,      :download ],
          [ '-e',             :sync_level,      :extract  ],
          [ '-b',             :sync_level,      :build    ],
          [ '-y',             :sync_level,      :install  ],
          [ '--build-dir /x', :build_directory, '/x'      ],
          [ '--ignore y',     :ignores,         ['y']     ]
        ].each do |flag, method, value|
          Options.parse! flag.split(' ')
          Config.send(method).should == value
        end

        [:color, :confirm, :devs, :source].each do |opt|
          Options.parse! ["--#{opt}"]
          Config.send("#{opt}?").should  be_true

          Options.parse! ["--no-#{opt}"]
          Config.send("#{opt}?").should be_false
        end

        Options.parse! ["--deps"]
        Config.resolve?.should be_true

        Options.parse! ["--no-deps"]
        Config.resolve?.should be_false

        Options.parse! ["--edit"]
        Config.edit?('foo').should be_true

        Options.parse! ["--no-edit"]
        Config.edit?('foo').should be_false

        Options.parse! ["-q"]
        Config.quiet?.should be_true

        Options.parse! ["--quiet"]
        Config.quiet?.should be_true
      end
    end

    it "passes through short makepkg options" do
      ['-c', '-f', '-L', '-r'].each do |opt|
        Options.parse! [opt]
        Config.makepkg_options.should include(opt)
      end
    end

    it "passes through long makepkg options" do
      [ ['--clean',    '-c'], ['--force',    '-f'],
        ['--log',      '-L'], ['--rmdeps',   '-r'],
        ['--asroot',    nil], ['--sign',      nil],
        ['--skipinteg', nil]
      ].each do |long, short|
        Options.parse! [long]
        Config.makepkg_options.should include(short || long)
      end
    end
  end
end
