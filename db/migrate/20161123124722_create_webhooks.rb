class CreateWebhooks < ActiveRecord::Migration[5.0]
  def change
    create_table :webhooks do |t|
      t.string :title, null: false, default: ''
      t.string :url, null: false, default: ''

      t.timestamps
    end
  end
end
