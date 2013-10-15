# -*- encoding : utf-8 -*-
module WeatherHelper

  include CityCode

  @@HEADER = { "Referer" => "http://mobile.weather.com.cn", 
    "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1664.3 Safari/537.36" }

  @@WEATHER_CACHE_EXPIRE_TIME = 30.minutes

  def get_weather_info_by_cityno_v2(city_no)
    begin
      raise unless city_no

      Rails.cache.fetch(["v2", :weather, city_no], expires_in: @@WEATHER_CACHE_EXPIRE_TIME) do
        today_weather_info = get_today_weather_info_v2(city_no)

        today_weather = today_weather_info['sk_info']

        weather_info = { 'current' => {}, 'forecasts' => [] }
        weather_info['current']['city'] = today_weather['cityName']
        weather_info['current']['cityid'] = city_no
        weather_info['current']['temp'] = remove_temp(today_weather['temp'])
        weather_info['current']['WD'] = today_weather['wd']
        weather_info['current']['WS'] = today_weather['ws']
        weather_info['current']['SD'] = today_weather['sd']
        weather_info['current']['time'] = today_weather['time']
        weather_info['current']['date_y'] = Time.now.strftime("%Y年%m月%d日")

        # index
        weather_info['current']['index_chuanyi'] = ""
        weather_info['current']['index_uv'] = ""
        weather_info['current']['index_xiche'] = ""
        weather_info['current']['index_comfort'] = ""
        weather_info['current']['index_chenlian'] = ""
        weather_info['current']['index_guomin'] = ""

        # 6天预报
        week_weather = get_week_weather_info_v2(city_no)['f']['f1']
        (1...7).each do |i|
          weather_info['forecasts'] << 
            {'temp' => "#{week_weather[i]['fd']}℃~#{week_weather[i]['fc']}℃", 'weather' => "", 'img' => "#{week_weather[i]['fa']}".to_i, 'wind' => ""}
        end

        weather_info
      end

    rescue Exception => e
      #binding.pry
      Rails.logger.error e
      nil
    end
  end

  def remove_temp(temp)
    temp.gsub(/℃/, '')
  end

  def get_weather_info_by_cityno(city_no)
    begin
      raise unless city_no

      Rails.cache.fetch([:weather, city_no], expires_in: @@WEATHER_CACHE_EXPIRE_TIME) do
        today_weather_info = get_today_weather_info(city_no)
        week_weather_info = get_week_weather_info(city_no)

        weather_info = {}

        # today
        weather_info['current'] = today_weather_info['weatherinfo']
        #weather_info['current']['date_y'] = week_weather_info['weatherinfo']['date_y']
        weather_info['current']['date_y'] = Time.now.strftime("%Y年%m月%d日")
        weather_info['current'].delete('isRadar')
        weather_info['current'].delete('Radar')
        weather_info['current'].delete('WSE')

        parse_no_content(weather_info['current'])

        # index
        weather_info['current']['index_chuanyi'] = week_weather_info['weatherinfo']['index']
        weather_info['current']['index_uv'] = week_weather_info['weatherinfo']['index_uv']
        weather_info['current']['index_xiche'] = week_weather_info['weatherinfo']['index_xc']
        weather_info['current']['index_comfort'] = week_weather_info['weatherinfo']['index_co']
        weather_info['current']['index_chenlian'] = week_weather_info['weatherinfo']['index_cl'] 
        weather_info['current']['index_guomin'] = week_weather_info['weatherinfo']['index_ag']

        # 6天预报
        forecasts= week_weather_info['weatherinfo']

        weather_info['forecasts'] = []
        (1...7).each do |i|
          weather_info['forecasts'] << 
            {'temp' => forecasts["temp#{i}"], 'weather' => forecasts["weather#{i}"], 'img' => forecasts["img#{i * 2 - 1}"], 'wind' => forecasts["wind#{i}"]}
        end

        weather_info
      end

    rescue Exception => e
      Rails.logger.error e
      nil
    end
  end

  def parse_no_content(today_weather_info)
    today_weather_info['temp'].gsub!(/暂无实况/, "--")
    today_weather_info['WD'].gsub!(/暂无实况/, "--")
    today_weather_info['WS'].gsub!(/暂无实况/, "--")
    today_weather_info['SD'].gsub!(/暂无实况/, "--")
  end

  def get_week_weather_info(city_no)
    Rails.cache.fetch([:weather, :week, city_no], expires_in: @@WEATHER_CACHE_EXPIRE_TIME) do
      MultiJson.load(HTTParty.get("http://m.weather.com.cn/data/#{city_no}.html"))
    end
  end

  def get_week_weather_info_v2(city_no)
    Rails.cache.fetch(["v2", :weather, :week, city_no], expires_in: @@WEATHER_CACHE_EXPIRE_TIME) do
      request_url = "http://mobile.weather.com.cn/data/forecast/#{city_no}.html?_=#{Time.now.to_i * 1000}"
      MultiJson.load(HTTParty.get(request_url, :headers => @@HEADER))
    end
  end

  def get_today_weather_info(city_no)
    Rails.cache.fetch([:weather, :today, city_no], expires_in: @@WEATHER_CACHE_EXPIRE_TIME) do
      MultiJson.load(HTTParty.get("http://www.weather.com.cn/data/sk/#{city_no}.html"))
    end
  end

  def get_today_weather_info_v2(city_no)
    Rails.cache.fetch(["v2", :weather, :today, city_no], expires_in: @@WEATHER_CACHE_EXPIRE_TIME) do
      request_url = "http://mobile.weather.com.cn/data/sk/#{city_no}.html?_=#{Time.now.to_i * 1000}"
      MultiJson.load(HTTParty.get(request_url, :headers => @@HEADER))
    end
  end

  def get_city_no_by_lat_lon(lat, lng)
    begin
      Rails.cache.fetch([:lat, lat, :lng, lng], expires_in: 1.day) do
        url = "http://api.map.baidu.com/geocoder?output=json&key=37492c0ee6f924cb5e934fa08c6b1676&location=#{lat},#{lng}"
        response = MultiJson.load(HTTParty.get(url).body)
        
        city_name = response['result']['addressComponent']['city']

        get_city_no_by_name(city_name)
      end
    rescue Exception => e
      Rails.logger.error e
      nil
    end
  end

  def get_city_no_by_name(city_name)
      if city_name
        city_name = get_city_name(city_name)
        @@CITY_CODE.each_pair do |key, value|
          if city_name.end_with? value
            return key.dup
          end
        end
      end
      nil
  end

  def get_city_name(input_city_name)
    input_city_name.gsub(/.*省/, '').gsub(/市.*/, '')
  end
end
