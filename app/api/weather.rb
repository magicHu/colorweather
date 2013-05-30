# encoding: utf-8
require 'city_code'

module Weather
  class API < Grape::API
    
    version 'v1', :using => :header, :vendor => 'colorweather'
    format  :xml

    helpers WeatherHelper
    helpers WechatHelper

    resource :weather do
      
      desc "通过cityno获取城市天气信息"
      params do
        requires :cityno, :type => String, :desc => "请输入城市编号."
      end
      get 'city/:cityno' do
        get_weather_info_by_cityno(params[:cityno]).to_json
      end

      desc '根据经纬度获取天气信息'
      get 'lat/:lat/lng/:lng', :requirements => {:lat => /\-*\d+.\d+/, :lng => /\-*\d+.\d+/} do
        city_no = get_city_by_lat_lon(params[:lat], params[:lng])

        unless city_no
          error!('Unexpect lat and lng', 400)
        end

        get_weather_info_by_cityno(city_no).to_json
      end
      
      desc '获取版本信息'
      get :version do
        Setting.last.to_json
      end

      desc '彩虹天气微信接口'
      post :weixin do
        request_body = request.body.read
        Rails.logger.info request_body
        if (params[:echostr]) 
          check_sign(params)
        else 
          response = get_city_weather_weixin(request_body)
        end
        Rails.logger.info response
        response
      end
    end
  end
end
