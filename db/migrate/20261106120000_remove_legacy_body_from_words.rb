class RemoveLegacyBodyFromWords < ActiveRecord::Migration[8.0]
  def up
    # words.body predates has_rich_text :body. Nothing reads the column
    # anymore (Word#body returns the ActionText rich text), and its presence
    # in schema.rb made readers wonder which column was the source of truth.
    remove_column :words, :body
  end

  def down
    add_column :words, :body, :text, default: "", null: false
  end
end
