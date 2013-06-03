require 'spec_helper'

describe WechatHelper do
  
  include WechatHelper

  it "parse temp" do
    # "33℃~19℃"
    "19/33℃".should == parse_temp("33℃~19℃")
  end

end
