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
       <ToUserName><![CDATA[colorweather]]></ToUserName>
       <FromUserName><![CDATA[jobs]]></FromUserName> 
       <CreateTime>1348831860</CreateTime>
       <MsgType><![CDATA[text]]></MsgType>
       <Content><![CDATA[上海]]></Content>
       <MsgId>1234567890123456</MsgId>
     </xml>
    EOF

    post "/weather/weixin?signature=37f3f3dc7aa56b505538e8bb323f629949767229&timestamp=1369898060&nonce=1370416851", request_body
    response.status.should == 201

    puts response.body
    node = Nokogiri::XML(response.body).xpath('//xml')
    "jobs".should == node.xpath('ToUserName').text
    "colorweather".should == node.xpath('FromUserName').text
    "news".should ==  node.xpath('MsgType').text
  end

  it "get no exist city weather info" do
    request_body = <<-EOF 
      <xml>
       <ToUserName><![CDATA[colorweather]]></ToUserName>
       <FromUserName><![CDATA[jobs]]></FromUserName> 
       <CreateTime>1348831860</CreateTime>
       <MsgType><![CDATA[text]]></MsgType>
       <Content><![CDATA[天朝]]></Content>
       <MsgId>1234567890123456</MsgId>
     </xml>
    EOF

    post "/weather/weixin?signature=37f3f3dc7aa56b505538e8bb323f629949767229&timestamp=1369898060&nonce=1370416851", :body => request_body
    response.status.should == 201

    node = Nokogiri::XML(response.body).xpath('//xml')
    "jobs".should == node.xpath('ToUserName').text
    "colorweather".should == node.xpath('FromUserName').text
    "text".should ==  node.xpath('MsgType').text
    "请输入城市名称，比如:北京,上海,纽约,伦敦".should ==  node.xpath('Content').text
  end

  it "test check weixin token" do
    # signature  微信加密签名
    # timestamp  时间戳
    # nonce  随机数
    # echostr  随机字符串
    timestamp = Time.new.to_i.to_s
    nonce = "random"
    echostr = "hello world"
    token = "colorweather"

    signature = Digest::SHA1.hexdigest([token, timestamp, nonce].sort.join)

    post "/weather/weixin", { :timestamp => timestamp, :nonce => nonce, :echostr => echostr, :signature => signature }
    response.status.should == 201
    echostr.should == response.body
  end

end
