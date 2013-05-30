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

    puts response.body
    #weather_info = Nokogiri::XML(response.body)
  end

  it "test check weixin token" do
    # signature  微信加密签名
    # timestamp  时间戳
    # nonce  随机数
    # echostr  随机字符串
    timestamp = Time.new.to_i.to_s
    nonce = "random"
    echostr = "echostr"
    token = "colorweather"

    signature = Digest::SHA1.hexdigest([token, timestamp, nonce].sort.join)

    get "/weather/weixin", { :timestamp => timestamp, :nonce => nonce, :echostr => echostr, :signature => signature }
    response.status.should == 200
    echostr.should == response.body
  end

end
