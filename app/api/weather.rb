require 'city_code'

module Weather
  class API < Grape::API
    
    version 'v1', :using => :header, :vendor => 'colorweather'
    format :json

    include CityCode

    helpers WeatherHelper

    resource :weather do
      
      desc "通过cityno获取城市天气信息"
      params do
        requires :cityno, :type => String, :desc => "请输入城市编号."
      end
      get 'city/:cityno'do
        get_weather_info_by_cityno(params[:cityno])
      end

      desc 'get weather by lat and lng'
      get 'lat/:lat/lng/:lng' do
        city_no = get_city_by_lat_lon(params[:lat], params[:lng])

        unless city_no
          error!('Unexpect lat and lng', 400)
        end

        get_weather_info_by_cityno(cityno)
      end
      
      desc 'get version info'
      get :version do

      end



      desc 'weixin callback'
      get :weixin do
        "hello world"
      end
    end

  end
end
