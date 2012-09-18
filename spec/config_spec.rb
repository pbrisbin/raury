require 'spec_helper'

module Raury
  describe Config do
    it "should expand build directory" do
      Config.instance.stub(:config).and_return({'build_directory' => './'})

      Config.build_directory.should == Dir.pwd
    end

    it "should have an ignore helper" do
      Config.instance.stub(:ignores).and_return([:foo])

      Config.ignore?(:foo).should be_true
      Config.ignore?(:baz).should be_false
    end

    it "should have a color helper" do
      $stdout.stub(:tty?).and_return(false)

      Config.instance.stub(:color).and_return(:always)
      Config.color?.should be_true

      Config.instance.stub(:color).and_return(:auto)
      Config.color?.should be_false

      $stdout.stub(:tty?).and_return(true)
      Config.color?.should be_true

      Config.instance.stub(:color).and_return(:never)
      Config.color?.should be_false
    end

    it "should have an edit helper" do
      Config.instance.stub(:edit).and_return(:prompt)

      Config.instance.should_receive(:prompt).with('Edit PKGBUILD for foo').and_return(false)
      Config.edit?('foo').should be_false

      Config.instance.stub(:edit).and_return(:always)
      Config.edit?('foo').should be_true

      Config.instance.stub(:edit).and_return(:never)
      Config.edit?('foo').should be_false
    end

    it "should have a development helper" do
      Config.instance.stub(:development_regex).and_return(/^foo/)

      Config.development_pkg?('foo-bar').should be_true
      Config.development_pkg?('bar-bar').should be_false
    end

  end
end
