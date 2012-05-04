require 'raury'

describe Raury::Search do
  it "should return search results" do
    Raury::Json.any_instance.stub(:content =>
      JSON.parse(File.read('./spec/json/cower_search.json')))

    results = Raury::Search.new('cower').call

    results.length.should eq(1)

    result = results.first
    result.name.should eq('cower')
    result.version.should eq('5-1')
    result.description.should eq('A simple AUR agent with a pretentious name')
    result.pkg_url.should eq('/packages/co/cower/cower.tar.gz')
  end
end
