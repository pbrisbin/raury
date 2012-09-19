require 'spec_helper'

module Raury
  describe Build do
    before do
      Dir.stub(:chdir).and_yield
      File.stub(:exists?).and_return(true)

      Config.stub(:edit?).and_return(false)
      Config.stub(:makepkg_options).and_return([])
    end

    it "should build and install package" do
      b = Build.new('aurget')
      b.should_receive(:system).with('makepkg', '-i').and_return(true)
      b.build
    end

    it "should add makepkg options for resolving" do
      Config.stub(:resolve?).and_return(true)

      b = Build.new('aurget')
      b.should_receive(:system).with('makepkg', '-s', '-i').and_return(true)
      b.build
    end

    it "should add makepkg options for color/confirm" do
      Config.stub(:color?).and_return(false)
      Config.stub(:confirm?).and_return(false)

      b = Build.new('aurget')
      b.should_receive(:system).with('makepkg', '--nocolor', '--noconfirm', '-i').and_return(true)
      b.build
    end

    it "should ask about editing" do
      Config.stub(:edit?).and_return(true)

      b = Build.new('aurget')
      b.should_receive(:system).with("#{Config.editor} 'PKGBUILD'").and_return(true)
      b.stub(:prompt).and_return(false) # so we don't continue
      b.build
    end

    it "should raise when not extracted" do
      Dir.stub(:chdir).and_raise(Errno::ENOENT)

      lambda { Build.new('aurget').build }.should raise_error(NoPkgbuild)
    end

    it "should raise when no PKGBUILD" do
      File.stub(:exists?).and_return(false)

      lambda { Build.new('aurget').build }.should raise_error(NoPkgbuild)
    end

    it "should raise when makepkg fails" do
      b = Build.new('aurget')
      b.should_receive(:system).with('makepkg', '-i').and_return(false)

      lambda { b.build }.should raise_error(BuildError)
    end

    it "should raise when editor fails" do
      Config.stub(:edit?).and_return(true)

      b = Build.new('aurget')
      b.should_receive(:system).with("#{Config.editor} 'PKGBUILD'").and_return(false)

      lambda { b.build }.should raise_error(EditError)
    end
  end
end
