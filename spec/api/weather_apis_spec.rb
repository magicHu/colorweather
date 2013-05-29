require 'spec_helper'

describe Weather::API do

  it "get city weather info by city no" do
    city_no = "101010100"
    get "/weather/city/#{city_no}"
    response.status.should == 200
    weather_info = MultiJson.load(response.body)

    "北京".should == weather_info["current"]["city"]
    city_no.should == weather_info["current"]["cityid"]
    6.should == weather_info["forecasts"].size
  end

  it "get city weather info by no exist city no" do
    get "/weather/city/noexist"
    response.status.should == 400
  end

  it "get city weather info by lat and lng" do
    lat, lng = 31.196375, 121.4354
    get "/weather/lat/#{lat}/lng/#{lng}"
    response.status.should == 200

    weather_info = MultiJson.load(response.body)
    "上海".should == weather_info["current"]["city"]
    "101020100".should == weather_info["current"]["cityid"]
    6.should == weather_info["forecasts"].size
  end

  it "get city info from weixin" do
    request_body = <<-EOF 
      <xml>
       <ToUserName><![CDATA[john]]></ToUserName>
       <FromUserName><![CDATA[jobs]]></FromUserName> 
       <CreateTime>1348831860</CreateTime>
       <MsgType><![CDATA[text]]></MsgType>
       <Content><![CDATA[上海]]></Content>
       <MsgId>1234567890123456</MsgId>
     </xml>
    EOF

    post "/weather/weixin", request_body
    response.status.should == 201

    weather_info = Nokogiri::XML(response.body)
  end

end
