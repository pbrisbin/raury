require 'spec_helper'
require 'stringio'

module Raury
  describe Output do
    let(:subject) { Class.new { include Output }.new }

    before do
      Config.stub(:debug?).and_return(true)
      Config.stub(:color?).and_return(true)

      @prev_stdout = $stdout
      @prev_stderr = $stderr

      $stdout      = StringIO.new
      $stderr      = StringIO.new
    end

    after do
      $stdout = @prev_stdout
      $stderr = @prev_stderr
    end

    it "can print debug stuffs" do
      subject.debug_box do
        subject.debug "a line"
        subject.debug "another line"
      end

      $stderr.string.should == "\e[30;1m
--------------------------------------------------------------------------------\e[0m
\e[30;1ma line\e[0m
\e[30;1manother line\e[0m
\e[30;1m--------------------------------------------------------------------------------
\e[0m
"
    end

    it "prints warnings" do
      subject.warn "A warning!"

      $stderr.string.should == "\e[33;1mwarning:\e[0m A warning!\n"
    end

    it "prints errors" do
      subject.error "An error!"

      $stderr.string.should == "\e[31;1merror:\e[0m An error!\n"
    end
  end
end
