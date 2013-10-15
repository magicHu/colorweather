# -*- encoding : utf-8 -*-
require 'spec_helper'

describe WeatherHelper do
  
  include WeatherHelper

  it "parse city name" do
    expect_city_name = "大连"

    expect_city_name.should == get_city_name("大连")
    expect_city_name.should == get_city_name("辽宁省大连")
    expect_city_name.should == get_city_name("辽宁省大连市")
    expect_city_name.should == get_city_name("辽宁省大连市xx区")
  end

  it "get city weather info" do
    city_no = "101010100"
    #puts get_weather_info_by_cityno(city_no)

    puts get_weather_info_by_cityno_v2(city_no)    
  end

  it "get city weather info new test" do
    city_no = "101010100"
    puts get_today_weather_info(city_no)
    puts get_today_weather_info_v2(city_no)
  end
end
