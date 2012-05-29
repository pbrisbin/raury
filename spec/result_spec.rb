require 'spec_helper'

describe Raury::Result do
  before do
    Raury::Config.config['color'] = false
  end

  context "instance" do
    search_result = Raury::Result.new(
      :search,
      JSON.parse(
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
    )

    it "has all the unconverted accessors" do
      search_result.description.should eq("A description")
      search_result.license.should eq("MIT")
      search_result.maintainer.should eq("pbrisbin")
      search_result.name.should eq("foo")
      search_result.pkg_url.should eq("\/packages\/fo\/foo\/foo.tar.gz")
      search_result.url.should eq("http:\/\/github.com\/pbrisbin\/foo")
      search_result.version.should eq("2.2-1")
    end

    it "has properly converted accessors" do
      search_result.pkg_id.should eq(12)
      search_result.category.should eq(16)
      search_result.votes.should eq(100)
      search_result.out_of_date.should eq(false)
      search_result.submitted.should eq(Time.at(1293676237))
      search_result.modified.should eq(Time.at(1334506297))
    end

    it "can be compared" do
      search_result_a = Raury::Result.new(:search,
        JSON.parse('{ "Name": "apple" }'))

      search_result_b = Raury::Result.new(:search,
        JSON.parse('{ "Name": "apple" }'))

      search_result_c = Raury::Result.new(:search,
        JSON.parse('{ "Name": "bean" }'))

      # same name, should eq
      search_result_a.should eq(search_result_b)

      # should sort by name
      [search_result_c, search_result_a].sort.should eq(
        [search_result_a, search_result_c])
    end
  end
end
