require 'raury'

describe Raury::Json do
  it "parses json content" do
    json = '{"Foo":1, "Bar":true}'

    Net::HTTP.stub(:get).and_return(json)

    j = Raury::Json.new("http://google.com")
    j.content.should eq(JSON.parse(json))
  end
end
