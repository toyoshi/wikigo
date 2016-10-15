class CreateOptions < ActiveRecord::Migration[5.0]
  def change
    create_table :options do |t|
      t.string :option_key, null: false, default: ""
      t.text :option_value, null: false, default: ""

      t.timestamps
    end
  end
end
