module Words
  # Wipes wiki content back to a clean slate: deletes all tags and every word
  # except the protected pages (Main Page / Side Bar), then resets those two
  # pages to their default bodies. Returns the counts that were removed.
  class ResetContent
    Result = Struct.new(:deleted_count, :tags_count)

    PROTECTED_TITLES = ['Main Page', 'Side Bar'].freeze

    def call
      # Delete all tags first
      tags_count = ActsAsTaggableOn::Tag.count
      ActsAsTaggableOn::Tag.destroy_all

      # Delete all words except Main Page and Side Bar
      deleted_count = Word.where.not(title: PROTECTED_TITLES).destroy_all.count

      # Reset Main Page and Side Bar to default content
      if (main_page = Word.find_by(title: 'Main Page'))
        main_page.update(body: "Wiki wiki go!", tag_list: [])
      end

      if (side_bar = Word.find_by(title: 'Side Bar'))
        side_bar.update(body: "--- menu ---", tag_list: [])
      end

      Result.new(deleted_count, tags_count)
    end
  end
end
