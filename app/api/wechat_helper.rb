# encoding: utf-8
module WechatHelper
  include WeatherHelper

  def get_city_weather_weixin(request_body)
    begin
      request_params = parse_weixin_request_body(request_body)

      if 'text' == request_params[:msg_type]
        weather_info = get_weather_info(request_params[:city_name])
        return response_weixin_format(request_params, weather_info)
      end
    rescue Exception => e 
      puts e
      return default_response
    end
  end

  def parse_weixin_request_body(request_body)
    node = Nokogiri::XML(request_body).xpath('//xml')

    {
      :to_user_name => node.xpath('ToUserName').text,
      :from_user_name => node.xpath('FromUserName').text,
      :create_time => node.xpath('CreateTime').text,
      :msg_type => node.xpath('MsgType').text,
      :city_name => node.xpath('Content').text,
      :msg_id => node.xpath('MsgId').text
    }
  end

  def response_weixin_format(request_params, weather_info)
    weather_infos = []
    weather_infos << { :weather => weather_info[:city], :img => image_big_url(weather_info[:img1].to_i) }
    weather_infos << { :weather => weather_info[:w1], :img => image_url(weather_info[:img1].to_i) }
    weather_infos << { :weather => weather_info[:w2], :img => image_url(weather_info[:img2].to_i) }
    weather_infos << { :weather => weather_info[:w3], :img => image_url(weather_info[:img3].to_i) }

    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.xml {
        xml.ToUserName { xml.cdata request_params[:from_user_name] }
        xml.FromUserName { xml.cdata request_params[:to_user_name] }
        xml.CreateTime { Time.now.to_i }
        xml.MsgType { xml.cdata "news" }
        xml.ArticleCount { xml.cdata weather_infos.length }

        xml.Articles {
          weather_infos.each do |weather_info|
            xml.Item {
              xml.Title { xml.cdata weather_info[:weather] }
              xml.Discription { xml.cdata "" }
              xml.PicUrl { xml.cdata weather_info[:img] }
              xml.Url { xml.cdata "http://item.taobao.com/item.htm?id=23879048548" }
            }
          end
        }
        xml.FuncFlag 0
      }
    end
    builder
  end

  def check_sign(params) 
    # 将token、timestamp、nonce三个参数进行字典序排序
    # 将三个参数字符串拼接成一个字符串进行sha1加密
    expect_sign = Digest::SHA1.hexdigest([token, params['timestamp'], params['nonce']].sort.join)

    if expect_sign == params['signature']
      return params['echostr'] 
    else
      return 'error'
    end
  end

  def get_weather_info(city_name)
    city_no = get_city_no_by_name(city_name)
    return default_response unless city_no

    week_weather_info = get_week_weather_info(city_no)
    return parse_weather_info(week_weather_info)
  end

  def parse_weather_info(weather_info)
    week_weather_info = weather_info["weatherinfo"]
    today_temp = parse_temp(week_weather_info["temp1"])
    tomorrow_temp = parse_temp(week_weather_info["temp2"])
    after_tomorrow_temp = parse_temp(week_weather_info["temp3"])

    wind = parse_wind(week_weather_info["wind1"])

    {
      :city => week_weather_info["city"],
      #"city" =>$data['city'].' '.$time.' '.$data['weather1'],
      :w1 => "今日 #{week_weather_info["weather1"]} , #{today_temp}, #{wind}",
      :w2 => "明天 #{week_weather_info["weather2"]} , #{tomorrow_temp}",
      :w3 => "后天 #{week_weather_info["weather3"]} , #{after_tomorrow_temp}",
      :img1 => week_weather_info["img1"],
      :img2 => week_weather_info["img3"],
      :img3 => week_weather_info["img5"]
    }
  end

  private
  # "19℃~22℃" => "19/22"
  def parse_temp(temp)
    temp.gsub(/℃/, "").gsub(/~/, "/") + "℃"
  end

  def parse_wind(wind)
    wind.gsub(/转.*/, '')
  end

  def parse_date(date)
    return date.gsub(/\d*年/, '')
  end

  def parse_week(week)
    return week.gsub(/星期/, "周")
  end

  def token
    'colorweather'
  end

  def default_response
    Rails.cache.fetch([:weixin, :defaultresponse], expires_in: 1.day) do
      "请输入城市名称，比如:北京,上海,纽约,伦敦"
    end
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
