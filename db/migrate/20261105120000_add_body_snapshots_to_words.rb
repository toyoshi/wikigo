class AddBodySnapshotsToWords < ActiveRecord::Migration[8.0]
  def up
    # body_plain_text: tag-free copy of the ActionText body, searchable (#83)
    # body_snapshot:   HTML copy captured per save for version history (#82)
    add_column :words, :body_plain_text, :text
    add_column :words, :body_snapshot, :text

    # Backfill existing rows so they are searchable and have history at once.
    # update_columns skips callbacks and PaperTrail, so the repair stays quiet.
    Word.unscoped.find_each(batch_size: 100) do |word|
      rich_text = word.body
      word.update_columns(
        body_plain_text: rich_text.try(:to_plain_text).to_s,
        body_snapshot: rich_text&.body&.fragment&.to_s.to_s
      )
    end

    # Versions written by the old YAML serializer carry ruby-object tags and
    # can not be loaded by the JSON serializer (nor by Psych safe load on Ruby
    # 4.0, which is what broke #82). They are unusable either way, so drop them;
    # versions created after this migration serialize as JSON and reify.
    PaperTrail::Version.where("object LIKE ?", "%!ruby/%").delete_all
    PaperTrail::Version.where("object_changes LIKE ?", "%!ruby/%").delete_all
  end

  def down
    remove_column :words, :body_plain_text
    remove_column :words, :body_snapshot
  end
end
