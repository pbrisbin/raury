require 'spec_helper'

describe Raury::Options do
  before do
    # ensure configs are rest to defaults between tests
    Raury::Config.instance.instance_eval do
      @config = Raury::Config::DEFAULTS.dup
    end
  end

  it "handles common commands correctly" do
    command, arguments = Raury::Options.parse! %w[ -S aurget ]
    
    command.should == :sync
    arguments.should == ['aurget']

    command, arguments = Raury::Options.parse! %w[ -Syu ]
    
    command.should == :upgrade
    arguments.should be_empty
    Raury::Config.sync_level.should == :install

    command, arguments = Raury::Options.parse! %w[ -Ss aur helper ]
    
    command.should == :search
    arguments.should == ['aur', 'helper']

    command, arguments = Raury::Options.parse! %w[ -Ssi aurget ]
    
    command.should == :info
    arguments.should == ['aurget']
  end

  it "handles options correctly" do
    [ [ '-d',             :sync_level,      :download ],
      [ '-e',             :sync_level,      :extract  ],
      [ '-b',             :sync_level,      :build    ],
      [ '-y',             :sync_level,      :install  ],
      [ '--build-dir /x', :build_directory, '/x'      ],
      [ '--ignore y',     :ignores,         ['y']     ]
    ].each do |flag, method, value|
      Raury::Options.parse! flag.split(' ')
      Raury::Config.send(method).should == value
    end

    [:color, :confirm, :source].each do |opt|
      Raury::Options.parse! ["--#{opt}"]
      Raury::Config.send("#{opt}?").should  be_true

      Raury::Options.parse! ["--no-#{opt}"]
      Raury::Config.send("#{opt}?").should be_false
    end

    Raury::Options.parse! ["--deps"]
    Raury::Config.resolve?.should be_true

    Raury::Options.parse! ["--no-deps"]
    Raury::Config.resolve?.should be_false

    Raury::Options.parse! ["--edit"]
    Raury::Config.edit?('foo').should be_true

    Raury::Options.parse! ["--no-edit"]
    Raury::Config.edit?('foo').should be_false

    Raury::Options.parse! ["-q"]
    Raury::Config.quiet?.should be_true

    Raury::Options.parse! ["--quiet"]
    Raury::Config.quiet?.should be_true
  end

  it "passes through short makepkg options" do
    ['-c', '-f', '-L', '-r'].each do |opt|
      Raury::Options.parse! [opt]
      Raury::Config.makepkg_options.should include(opt)
    end
  end

  it "passes through long makepkg options" do
    [ ['--clean',    '-c'], ['--force',    '-f'],
      ['--log',      '-L'], ['--rmdeps',   '-r'],
      ['--asroot',    nil], ['--sign',      nil],
      ['--skipinteg', nil]
    ].each do |long, short|
      Raury::Options.parse! [long]
      Raury::Config.makepkg_options.should include(short || long)
    end
  end
end
