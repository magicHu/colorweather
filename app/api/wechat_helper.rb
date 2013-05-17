# encoding: utf-8
module WechatHelper

  def get_city_info_as_weather_format(xml)
    doc = Nokogiri::XML(xml)

    datas = []
    doc.xpath('//links/item').each do |node| 
      datas << {"title" => node.xpath('title').text, "url" => node.xpath('url').text}
    end
    datas
  end

  def response_weather_to_weixin(request_body)
    request_params = form_weather_request_format(request_body)

    if 'text' == request_params[:msg_type]
      city_no = get_city_no_by_name(request_params['city_name'])
      return default_response unless city_no

      weather_info = get_weather_info_by_cityno(city_no)
      return to_weixin_response_format(request_params, weather_info)
    end
  end

  def form_weather_request_format(request_body)
=begin
<xml>
 <ToUserName><![CDATA[toUser]]></ToUserName>
 <FromUserName><![CDATA[fromUser]]></FromUserName> 
 <CreateTime>1348831860</CreateTime>
 <MsgType><![CDATA[text]]></MsgType>
 <Content><![CDATA[this is a test]]></Content>
 <MsgId>1234567890123456</MsgId>
 </xml>
=end
    {
      :to_user_name => request_body['ToUserName'],
      :from_user_name => request_body['FromUserName'],
      :create_time => request_body['CreateTime'],
      :msg_type => request_body['MsgType']
      :city_name => request_body['Content']
      :msg_id => request_body['MsgId']
    }
  end

  def to_weixin_response_format(request_params, weather_info)
    $img0 = image_big_url(weather_info['img1']);
    $img1 = image_url(weather_info['img1']);
    $img2 = image_url(weather_info['img2']);
    $img3 = image_url(weather_info['img3']);

    # $fromUsername, $toUsername, $time, 
    # $data['city'], $img0, $data['w1'], $img1,  $data['w2'], $img2,  $data['w3'], $img3);

=begin
"<xml>
 <ToUserName><![CDATA[%s]]></ToUserName>
 <FromUserName><![CDATA[%s]]></FromUserName>
 <CreateTime>%s</CreateTime>
 <MsgType><![CDATA[news]]></MsgType>
 <Content><![CDATA[]]></Content>
 <ArticleCount>4</ArticleCount>
 <Articles>
 <item>
 <Title><![CDATA[%s]]></Title>
 <Discription><![CDATA[]]></Discription>
 <PicUrl><![CDATA[%s]]></PicUrl>
 <Url><![CDATA[http://item.taobao.com/item.htm?id=23879048548]]></Url>
 </item>
 <item>
 <Title><![CDATA[%s]]></Title>
 <Discription><![CDATA[]]></Discription>
 <PicUrl><![CDATA[%s]]></PicUrl>
 <Url><![CDATA[http://item.taobao.com/item.htm?id=23879048548]]></Url>
 </item>
 <item>
 <Title><![CDATA[%s]]></Title>
 <Discription><![CDATA[]]></Discription>
 <PicUrl><![CDATA[%s]]></PicUrl>
 <Url><![CDATA[http://item.taobao.com/item.htm?id=23879048548]]></Url>
 </item>
 <item>
 <Title><![CDATA[%s]]></Title>
 <Discription><![CDATA[]]></Discription>
 <PicUrl><![CDATA[%s]]></PicUrl>
 <Url><![CDATA[http://item.taobao.com/item.htm?id=23879048548]]></Url>
 </item>
 
 </Articles>
 <FuncFlag>0</FuncFlag>
 </xml> "
=end

  end

  def check_sign(params) 
    # 将token、timestamp、nonce三个参数进行字典序排序
    # 将三个参数字符串拼接成一个字符串进行sha1加密
    expect_sign = Digest::SHA1.new([token, params['timestamp'], params['nonce']].sort)

    if expect_sign == params['signature']
      return params['echostr'] 
    else
      return 'error'
    end
  end

  def token
    'colorweather'
  end

  def default_response
    "请输入城市名称，比如:北京,上海,纽约,伦敦"
  end

  @@IMAGE_IDS = ["32","34","26","37","45","45","5","9",
            "9","40","40","12","12","13","15","15",
            "15","41","20","12","24","12","9","9",
            "12","12","13","13","26","24","24","24"]

  @@IMAGE_BIG = ["day0","day1","day2","day3","day4","day4","day6","day8",
            "day8","day9","day9","day11","day11","day13","day15","day15",
            "day15","day17","day18","day8","day20","day8","day9","day9",
            "day11","day11","day15","day15","day17","day20","day20","day20"]

  def image_url(img)
    "http://image.thinkpage.cn/weather/images/icons/#{@@IMAGE_IDS[img]}.png";
  end

  def image_big_url(img)
    "http://colorweather.sinaapp.com/imgs/b#{@@IMAGE_BIG[img]}.png";
  end

end
