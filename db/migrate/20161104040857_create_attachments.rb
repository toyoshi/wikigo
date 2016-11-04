class CreateAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :attachments do |t|
      t.integer :user_id
      t.string :file

      t.timestamps
    end
  end
end
