class Setting < ActiveRecord::Base
  attr_accessible :download_url, :is_taobao, :notice, :tabao_message, :taobao_url, :version
end
