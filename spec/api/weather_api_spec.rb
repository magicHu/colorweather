require 'spec_helper'

describe Weather::API do

  it "get city weather info by city no" do
    city_no = "101010100"
    get "/v1/weather/city/#{city_no}"
    response.status.should == 200
    weather_info = MultiJson.load(response.body)

    "北京".should == weather_info["current"]["city"]
    city_no.should == weather_info["current"]["cityid"]
    6.should == weather_info["forecasts"].size
  end

  it "get city weather info by no exist city no" do
    get "/v1/weather/city/noexist"
    response.status.should == 400
  end

  it "get city weather info by lat and lng" do
    lat, lng = 31.196375, 121.4354
    get "/v1/weather/lat/#{lat}/lng/#{lng}"
    response.status.should == 200

    weather_info = MultiJson.load(response.body)
    "上海".should == weather_info["current"]["city"]
    "101020100".should == weather_info["current"]["cityid"]
    6.should == weather_info["forecasts"].size
  end

end
