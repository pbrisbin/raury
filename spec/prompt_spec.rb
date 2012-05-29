require 'spec_helper'

describe Raury::Prompt do
  before do
    @it = Class.new do
      include Raury::Prompt

    end.new
  end

  it "should output a message, default yes" do
    msg = "continue"

    @it.should_receive(:puts).with('')
    @it.should_receive(:print).with("#{msg}? ")
    @it.should_receive(:print).with('[Y/n] ')

    $stdin.stub(:gets).and_return('')

    @it.prompt(msg)
  end

  it "should output a message, default no" do
    msg = "continue"

    @it.should_receive(:puts).with('')
    @it.should_receive(:print).with("#{msg}? ")
    @it.should_receive(:print).with('[y/N] ')

    $stdin.stub(:gets).and_return('')

    @it.prompt(msg, false)
  end

  it "should get a response" do
    @it.stub(:puts)
    @it.stub(:print)

    $stdin.stub(:gets).and_return('y')

    ( @it.prompt('yeah') && true ).should be_true

    $stdin.stub(:gets).and_return('n')

    ( @it.prompt('yeah') && true ).should be_false
  end

  it "should respect no-confirm" do
    Raury::Config.stub(:confirm?).and_return(false)

    @it.stub(:puts)
    @it.stub(:print)

    $stdin.should_not_receive(:gets)

    ( @it.prompt('yeah') && true ).should be_true
    ( @it.prompt('yeah', false) && true ).should be_false
  end

  it "should default on empty response" do
    @it.stub(:puts)
    @it.stub(:print)

    $stdin.should_receive(:gets).twice.and_return('')

    ( @it.prompt('yeah') && true ).should be_true
    ( @it.prompt('yeah', false) && true ).should be_false
  end
end
