require 'spec_helper'

describe Wechat::API do
  
  let(:request_body) {
    <<-EOF 
      <xml>
       <ToUserName><![CDATA[colorweather]]></ToUserName>
       <FromUserName><![CDATA[jobs]]></FromUserName> 
       <CreateTime>1348831860</CreateTime>
       <MsgType><![CDATA[text]]></MsgType>
       <Content><![CDATA[上海]]></Content>
       <MsgId>1234567890123456</MsgId>
     </xml>
    EOF
  }

  let(:noexist_city_request_body) {
    <<-EOF 
      <xml>
       <ToUserName><![CDATA[colorweather]]></ToUserName>
       <FromUserName><![CDATA[jobs]]></FromUserName> 
       <CreateTime>1348831860</CreateTime>
       <MsgType><![CDATA[text]]></MsgType>
       <Content><![CDATA[天朝]]></Content>
       <MsgId>1234567890123456</MsgId>
     </xml>
    EOF
  }

  it "get city info from weixin" do
    post "/v1/weixin", request_body
    response.status.should == 200

    puts response.body
    node = Nokogiri::XML(response.body).xpath('//xml')
    "jobs".should == node.xpath('ToUserName').text
    "colorweather".should == node.xpath('FromUserName').text
    "news".should ==  node.xpath('MsgType').text
    "4".should ==  node.xpath('ArticleCount').text
  end

  it "get no exist city weather info" do
    post "/v1/weixin", noexist_city_request_body
    response.status.should == 200

    node = Nokogiri::XML(response.body).xpath('//xml')
    "jobs".should == node.xpath('ToUserName').text
    "colorweather".should == node.xpath('FromUserName').text
    "text".should ==  node.xpath('MsgType').text
    "请直接输入城市名称，比如: 北京，上海，大连，西安，成都。如果内容包含省份信息，以及语音信息神马的我都不认识哟。谢谢 ^_^".should ==  node.xpath('Content').text
  end

  it "test check weixin token" do
    # signature  微信加密签名
    # timestamp  时间戳
    # nonce  随机数
    # echostr  随机字符串
    timestamp = Time.new.to_i.to_s
    nonce = "random"
    echostr = "helloworld"
    token = "colorweather"

    signature = Digest::SHA1.hexdigest([token, timestamp, nonce].sort.join)

    params = { :timestamp => timestamp, :nonce => nonce, :echostr => echostr, :signature => signature }
    get "/v1/weixin", params
    puts params.map{ |key, value| "#{key}=#{value}" }.join('&')

    response.status.should == 200
    echostr.should == response.body
  end
end
