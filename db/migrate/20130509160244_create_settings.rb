class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :version
      t.string :download_url
      t.string :notice
      t.boolean :is_taobao
      t.string :tabao_message
      t.string :taobao_url

      t.timestamps
    end
  end
end
