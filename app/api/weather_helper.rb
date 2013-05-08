module WeatherHelper

  include CityCode

  def get_weather_info_by_cityno(city_no)
    begin
      Rails.cache.fetch([:weather, city_no], expires_in: 30.minutes) do
        today_weather_info = MultiJson.load(HTTParty.get("http://www.weather.com.cn/data/sk/#{city_no}.html"))
        week_weather_info = MultiJson.load(HTTParty.get("http://m.weather.com.cn/data/#{city_no}.html"))

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
      error!('Unexpect result', 400)
    end
  end

  def get_city_by_lat_lon(lat, lng)
    begin
      Rails.cache.fetch([:lat, lat, :lng, lng], expires_in: 1.day) do
        url = "http://api.map.baidu.com/geocoder?output=json&key=37492c0ee6f924cb5e934fa08c6b1676&location=#{lat},#{lng}"
        response = MultiJson.load(HTTParty.get(url).body)
        
        city_name = response['result']['addressComponent']['city']

        city_no = nil
        if city_name
          @@CITY_CODE.each_pair do |key, value|
            if city_name.start_with? value
              city_no = key.dup
              break
            end
          end
        end
        city_no
      end
    rescue Exception => e
      Grape::API.logger.error e
      nil
    end
  end

end
