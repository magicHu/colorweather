require 'spec_helper'

describe WechatHelper do
  
  include WechatHelper

  it "parse temp" do
    # "19℃~33℃"
    "19/33℃".should == parse_temp("19℃~33℃")
  end

end
