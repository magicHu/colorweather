require 'spec_helper'

describe Weather::API do

  it "get city info from weixin" do
    get "/weather/weixin"
    response.status.should == 200
    puts response.body
  end
end
