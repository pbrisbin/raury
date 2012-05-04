require 'raury'

describe Raury::SearchResult do
  context "instance" do
    search_result = Raury::SearchResult.new(
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
  end
end
