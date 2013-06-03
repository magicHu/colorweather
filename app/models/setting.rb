class Setting < ActiveRecord::Base
  attr_accessible :download_url, :is_taobao, :notice, :tabao_message, :taobao_url, :version

  def self.get_version_setting
    Rails.cache.fetch([:weather, :version], expires_in: 1.day) do
      Setting.last
    end
  end

  after_save :delete_version_cache
  after_destroy :delete_version_cache

  private
  def delete_version_cache
    Rails.cache.delete([:weather, :version])
  end
end
