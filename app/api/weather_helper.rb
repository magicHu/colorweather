# encoding: utf-8
module WeatherHelper

  include CityCode

  @@CACHE_EXPIRES_IN = 10.minutes

  def get_weather_info_by_cityno(city_no)
    begin
      raise unless city_no

      binding.pry
      Rails.cache.fetch([:weather, city_no], expires_in: @@CACHE_EXPIRES_IN) do
        today_weather_info = get_tody_weather_info(city_no)
        week_weather_info = get_week_weather_info(city_no)

        binding.pry
        weather_info = {}

        # today
        weather_info['current'] = today_weather_info['weatherinfo']
        weather_info['current']['date_y'] = week_weather_info['weatherinfo']['date_y']
        weather_info['current'].delete('isRadar')
        weather_info['current'].delete('Radar')
        weather_info['current'].delete('WSE')

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
      Grape::API.logger.error e
      error!('Unexpect city info', 400)
    end
  end

  def get_week_weather_info(city_no)
    Rails.cache.fetch([:weather, :week, city_no], expires_in: @@CACHE_EXPIRES_IN) do
      url = "http://m.weather.com.cn/data/#{city_no}.html"
      puts url
      MultiJson.load(HTTParty.get())
    end
  end

  def get_tody_weather_info(city_no)
    Rails.cache.fetch([:weather, :today, city_no], expires_in: @@CACHE_EXPIRES_IN) do
      url = "http://www.weather.com.cn/data/sk/#{city_no}.html"
      puts url
      MultiJson.load(HTTParty.get())
    end
  end

  def get_city_by_lat_lon(lat, lng)
    begin
      Rails.cache.fetch([:lat, lat, :lng, lng], expires_in: 1.day) do
        url = "http://api.map.baidu.com/geocoder?output=json&key=37492c0ee6f924cb5e934fa08c6b1676&location=#{lat},#{lng}"
        response = MultiJson.load(HTTParty.get(url).body)
        
        city_name = response['result']['addressComponent']['city']

        get_city_no_by_name(city_name)
      end
    rescue Exception => e
      Grape::API.logger.error e
      nil
    end
  end

  def get_city_no_by_name(city_name)
      if city_name
        @@CITY_CODE.each_pair do |key, value|
          if city_name.start_with? value
            return key.dup
          end
        end
      end
      nil
  end
end
