require 'spec_helper'

describe Weather::API do

  it 'get weather by city no' do
    city_no = '101010100'
    get "/weather/city/#{city_no}"
    response.status.should == 200
    result = JSON.parse(response.body)

    #get "http://colorweather.sinaapp.com/mzjson.php?cityno=#{city_no}"
    #response.status.should == 200
    #expect_result = JSON.parse(response.body)

    #"expect_result".should == result
  end

  it 'get expect result' do
    city_no = '101010100'
    get "http://colorweather.sinaapp.com/mzjson.php?cityno=#{city_no}"
    response.status.should == 200
    expect_result = JSON.parse(response.body)

    expect_result.should == nil
  end


end
