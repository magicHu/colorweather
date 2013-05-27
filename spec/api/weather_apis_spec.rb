require 'spec_helper'

describe Weather::API do

  it "get city info from weixin" do
    request_body = <<-EOF
      <xml>
        <ToUserName><![CDATA[toUser]]></ToUserName>
        <FromUserName><![CDATA[fromUser]]></FromUserName> 
        <CreateTime>1348831860</CreateTime>
        <MsgType><![CDATA[text]]></MsgType>
        <Content><![CDATA[this is a test]]></Content>
        <MsgId>1234567890123456</MsgId>
      </xml>
    EOF

    request = { :format => 'xml', :application => request_body }
    post "/weather/weixin", request
    response.status.should == 201
    puts response.body
  end

  it "get city info by no exist city name" do
    
  end
end
