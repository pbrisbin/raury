require 'spec_helper'

describe Raury::Build do
  before do
    Dir.stub(:chdir).and_yield
    File.stub(:exists?).and_return(true)

    defs = Raury::Config::DEFAULTS.dup
    Raury::Config.instance.stub(:config).and_return(defs)
    Raury::Config.stub(:edit?).and_return(false)
    Raury::Config.stub(:makepkg_options).and_return([])
  end

  it "should build and install package" do
    b = Raury::Build.new('aurget')
    b.should_receive(:system).with('makepkg', '-i').and_return(true)
    b.build
  end

  it "should add makepkg options for resolving" do
    Raury::Config.stub(:resolve?).and_return(true)

    b = Raury::Build.new('aurget')
    b.should_receive(:system).with('makepkg', '-s', '-i').and_return(true)
    b.build
  end

  it "should add makepkg options for color/confirm" do
    Raury::Config.stub(:color?).and_return(false)
    Raury::Config.stub(:confirm?).and_return(false)

    b = Raury::Build.new('aurget')
    b.should_receive(:system).with('makepkg', '--nocolor', '--noconfirm', '-i').and_return(true)
    b.build
  end

  it "should raise when not extracted" do
    Dir.stub(:chdir).and_raise(Errno::ENOENT)

    lambda { Raury::Build.new('aurget').build }.should raise_error(Raury::NoPkgbuild)
  end

  it "should raise when no PKGBUILD" do
    File.stub(:exists?).and_return(false)

    lambda { Raury::Build.new('aurget').build }.should raise_error(Raury::NoPkgbuild)
  end
end
