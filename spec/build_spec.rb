require 'raury'

describe Raury::Build do
  it "should build a package" do
    Dir.stub(:chdir).and_yield
    File.stub(:exists?).and_return(true)

    Raury::Config.stub(:color?).and_return(true)
    Raury::Config.stub(:resolve?).and_return(false)
    Raury::Config.stub(:sync_level).and_return(:build)

    b = Raury::Build.new('aurget')
    b.should_receive(:system).with('makepkg').and_return(true)
    b.build
  end

  it "should add makepkg options" do
    Dir.stub(:chdir).and_yield
    File.stub(:exists?).and_return(true)

    Raury::Config.stub(:color?).and_return(false)
    Raury::Config.stub(:confirm?).and_return(false)
    Raury::Config.stub(:resolve?).and_return(true)
    Raury::Config.stub(:sync_level).and_return(:install)

    b = Raury::Build.new('aurget')
    b.should_receive(:system).with('makepkg', '--nocolor', '--noconfirm', '-s', '-i').and_return(true)
    b.build
  end

  it "should raise when not extracted" do
    Dir.stub(:chdir).and_raise(Errno::ENOENT)

    lambda { Raury::Build.new('aurget').build }.should raise_error(Raury::NoPkgbuild)
  end

  it "should raise when no PKGBUILD" do
    Dir.stub(:chdir).and_yield
    File.stub(:exists?).and_return(false)

    lambda { Raury::Build.new('aurget').build }.should raise_error(Raury::NoPkgbuild)
  end
end
