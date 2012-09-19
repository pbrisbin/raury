require 'spec_helper'
require 'stringio'

module Raury
  describe Result do
    let(:subject) do
      json = JSON.parse(
        '{ "Maintainer":"pbrisbin",
           "ID":"12",
           "Name":"foo",
           "Version":"2.2-1",
           "CategoryID":"16",
           "Description":"A description",
           "URL":"http:\/\/github.com\/pbrisbin\/foo",
           "License":"MIT",
           "NumVotes":"100",
           "OutOfDate":"0",
           "FirstSubmitted":"1293676237",
           "LastModified":"1334506297",
           "URLPath":"\/packages\/fo\/foo\/foo.tar.gz" }'
      )

      Result.new(:search, json)
    end

    before do
      Config.stub(:color?).and_return(false)
    end

    it "has all the unconverted accessors" do
      subject.description.should == "A description"
      subject.license.should     == "MIT"
      subject.maintainer.should  == "pbrisbin"
      subject.name.should        == "foo"
      subject.pkg_url.should     == "\/packages\/fo\/foo\/foo.tar.gz"
      subject.url.should         == "http:\/\/github.com\/pbrisbin\/foo"
      subject.version.should     == "2.2-1"
    end

    it "has properly converted accessors" do
      subject.pkg_id.should      == 12
      subject.category.should    == 16
      subject.votes.should       == 100
      subject.out_of_date.should == false
      subject.submitted.should   == Time.at(1293676237)
      subject.modified.should    == Time.at(1334506297)
    end

    it "can be compared" do
      search_result_a = Result.new(:search,
        JSON.parse('{ "Name": "apple" }'))

      search_result_b = Result.new(:search,
        JSON.parse('{ "Name": "apple" }'))

      search_result_c = Result.new(:search,
        JSON.parse('{ "Name": "bean" }'))

      # same name, should eq
      search_result_a.should == search_result_b

      # should sort by name
      [search_result_c, search_result_a].sort.should match_array([search_result_a, search_result_c])
    end

    context "when displaying" do
      before do
        @prev_stdout = $stdout
        $stdout      = StringIO.new
      end

      after do
        $stdout = @prev_stdout
      end

      it "respects quiet" do
        Config.stub(:quiet?).and_return(true)

        subject.display

        $stdout.string.should == "foo\n"
      end

      it "displays for search" do
        subject.stub(:type).and_return(:search)

        subject.display

        $stdout.string.should == "aur/foo 2.2-1\n    A description\n"
      end

      it "displays for info" do
        subject.stub(:type).and_return(:info)

        subject.display

        $stdout.string.should == [
          'Repository      : aur',
          'Name            : foo',
          'Version         : 2.2-1',
          'URL             : http://github.com/pbrisbin/foo',
          'License         : MIT',
          'Maintainer      : pbrisbin',
          'Submitted       : 2010-12-29 21:30:37 -0500',
          'Modified        : 2012-04-15 12:11:37 -0400',
          'Votes:          : 100',
          'Out of date     : No',
          'Description     : A description', '', ''
        ].join("\n")
      end
    end
  end
end
