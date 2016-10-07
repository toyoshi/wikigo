class CreateWords < ActiveRecord::Migration[5.0]
  def change
    create_table :words do |t|
      t.string :title, null: false, default: ""
      t.text :body, null: false, default: ""

      t.timestamps
    end
  end
end
