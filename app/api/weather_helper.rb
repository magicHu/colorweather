module WeatherHelper

  def get_weather_info_by_cityno(city_no)
    begin
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
        w = {'temp' => forecasts["temp#{i}"], 'weather' => forecasts["weather#{i}"], 'img' => forecasts["img#{i * 2 - 1}"], 'wind' => forecasts["wind#{i}"]}
        weather_info['forecasts'] << w
      end

      return weather_info
    rescue Exception => e
      logger.error e
      error!('Unexpect result', 400)
    end
  end

  def get_city_by_lat_lon(lat, lng)
    begin
      url = "http://api.map.baidu.com/geocoder?output=json&key=37492c0ee6f924cb5e934fa08c6b1676&location=#{lat},#{lng}"
      response = MultiJson.load(HTTParty.get(url))
      city_name = response['result']['addressComponent']['city']

      @@CITY_CODE.each_pair do |key, value|
        return key if value == city_name
      end
    rescue Exception => e
      nil
    end
  end

  def logger
    API.logger
  end
end
