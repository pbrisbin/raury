require 'raury'

describe Raury do
  it "prints invalid usage" do
    def when_given(&block)
      $stderr.should_receive(:puts).with('invalid usage, try -h or --help.')
      yield
    rescue SystemExit
    end

    # no command
    when_given { Raury.new('cower', 'haskell-yesod') }

    # no targets
    when_given { Raury.new('-S') }

    # invalid option
    when_given { Raury.new('-S', '--foo', 'cower') }

    # multiple commands
    when_given { Raury.new('-S', '-Si') }
  end

  it "accepts an install command" do
    r = Raury.new('-S', 'cower', 'haskell-yesod')

    r.command.should eq(:install)
    r.targets.should eq(['cower', 'haskell-yesod'])
  end
end
