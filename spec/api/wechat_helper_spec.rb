require 'spec_helper'

describe WechatHelper do

  include WechatHelper

  let(:request_body) {
     <<-EOF 
        <xml>
         <ToUserName><![CDATA[john]]></ToUserName>
         <FromUserName><![CDATA[jobs]]></FromUserName> 
         <CreateTime>1348831860</CreateTime>
         <MsgType><![CDATA[text]]></MsgType>
         <Content><![CDATA[上海]]></Content>
         <MsgId>1234567890123456</MsgId>
       </xml>
      EOF
  }

  let(:expect_request_params) {
    {
      :to_user_name => "john",
      :from_user_name => "jobs",
      :create_time => "1348831860",
      :msg_type => "text",
      :city_name => "上海",
      :msg_id => "1234567890123456"
    }
  }
  
  it 'get city weather info from weixin' do
    puts get_city_weather_weixin(request_body)
  end

  it 'parse weixin request boby' do
    parse_weixin_request_body(request_body).should == expect_request_params
  end

  it 'get weather info' do
    weather_info = get_weather_info("上海")
    puts weather_info
  end

  it "response as weixin format" do
    weather_info = <<-EOF
      {"city"=>"上海",
      "cityid"=>"101020100",
      "temp"=>"22",
      "WD"=>"北风",
      "WS"=>"0级",
      "SD"=>"62%",
      "time"=>"23:00",
      "date_y"=>"2013年5月20日",
      "index_chuanyi"=>"热",
      "index_uv"=>"很强",
      "index_xiche"=>"适宜",
      "index_comfort"=>"较舒适",
      "index_chenlian"=>"较适宜",
      "index_guomin"=>"易发"},
      "forecasts"=>
        [{"temp"=>"21℃~30℃", "weather"=>"多云转晴", "img"=>"1", "wind"=>"东南风3-4级"},
         {"temp"=>"20℃~28℃", "weather"=>"晴转多云", "img"=>"0", "wind"=>"东南风3-4级"},
         {"temp"=>"22℃~27℃", "weather"=>"多云转阴", "img"=>"1", "wind"=>"东南风3-4级"},
         {"temp"=>"21℃~27℃", "weather"=>"多云", "img"=>"1", "wind"=>"东南风3-4级"},
         {"temp"=>"21℃~27℃", "weather"=>"多云转阴", "img"=>"1", "wind"=>"东南风3-4级"},
         {"temp"=>"21℃~25℃", "weather"=>"阴转小雨", "img"=>"2", "wind"=>"东南风3-4级转4-5级"}]
      }
    EOF

    response_weixin_format(expect_request_params, weather_info).should == ""
  end

end
