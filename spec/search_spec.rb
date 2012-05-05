require 'raury'

describe Raury::Search do
  it "should return search results" do
    Raury::Aur.any_instance.stub(:fetch =>
      File.read('./spec/json/search_result.json'))

    results = Raury::Search.new(['aur', 'helper']).call

    results.length.should eq(1)

    result = results.first
    result.name.should eq('a_name')
    result.version.should eq('1-1')
    result.description.should eq('A description')
    result.pkg_url.should eq('/packages/fo/foo/foo.tar.gz')
  end
end
