require 'spec_helper'

describe Weather::API do

  it 'get weather by city no' do
    city_no = '101010100'
    get "/weather/city/#{city_no}"
    response.status.should == 200
    result = JSON.parse(response.body)

    expect_response = HTTParty.get("http://1.colorweather.sinaapp.com/mzjson.php?cityno=#{city_no}")
    expect_result = JSON.parse(expect_response.body)

    expect_result.should == result
  end

  it 'get weather by unexist city no' do
    not_exist_city_no = "not_exist_city_no"
    get "/weather/city/#{not_exist_city_no}"
    response.status.should == 400
  end

  it "get weather by lat and lng" do
    lat = "31.23691"
    lng = "121.50109"
    get "/weather/lat/#{lat}/lng/#{lng}"
    response.status.should == 200
    result = JSON.parse(response.body)

    expect_response = HTTParty.get("http://1.colorweather.sinaapp.com/mzjson.php?cityno=101020100")
    expect_result = JSON.parse(expect_response.body)

    expect_result.should == result
  end

end
