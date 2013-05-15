# encoding: utf-8
module WechatHelper

  def get_city_info_as_weather_format(xml)
    doc = Nokogiri::XML(xml)

    datas = []
    doc.xpath('//links/item').each do |node| 
      datas << {"title" => node.xpath('title').text, "url" => node.xpath('url').text}
    end
    datas
  end
end
