require 'test_helper'

class WordTest < ActiveSupport::TestCase
  test "format to middleman" do
    @word = words(:one)
    txt = @word.to_middleman
    expected = <<"EOS"
---
title: MyString
date: #{@word.created_at}
tags: Very good, Bad
wiki:word_id: #{@word.id}
---

#{@word.body.to_s}
EOS
    assert_equal expected, txt
  end

  # --- validations ---

  test "invalid without a title" do
    word = Word.new(title: nil)
    assert_not word.valid?
    assert_includes word.errors[:title], "can't be blank"
  end

  test "invalid with a blank title" do
    word = Word.new(title: "")
    assert_not word.valid?
  end

  test "invalid with a duplicate title" do
    duplicate = Word.new(title: words(:one).title)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:title], "has already been taken"
  end

  test "valid with a unique title" do
    word = Word.new(title: "A Brand New Title")
    assert word.valid?
  end

  # --- to_param / title conversion ---

  test "to_param replaces spaces with dashes" do
    word = Word.new(title: "Hello World Title")
    assert_equal "Hello-World-Title", word.to_param
  end

  test "to_param leaves titles without spaces untouched" do
    word = words(:one)
    assert_equal word.title, word.to_param
  end

  # --- self.find ---

  test "find by integer id delegates to the default finder" do
    word = words(:one)
    assert_equal word, Word.find(word.id)
  end

  test "find by string looks up by title, converting dashes to spaces" do
    word = Word.create!(title: "Dash Title Example")
    assert_equal word, Word.find("Dash-Title-Example")
  end

  test "find by string returns nil when no word matches the title" do
    # find_by_title (a dynamic finder) is used internally, so unlike the
    # integer/id branch this does not raise RecordNotFound.
    assert_nil Word.find("does-not-exist-anywhere")
  end

  # --- home page protection ---

  test "cannot destroy the word with id 1" do
    home = Word.new(id: 1, title: "Home Page")
    home.save!(validate: false)

    assert_equal false, home.destroy
    assert_includes home.errors[:base], "ホームページ（ID=1）は削除できません"
    assert Word.exists?(1)
  end

  test "can destroy a word whose id is not 1" do
    word = Word.create!(title: "Disposable Word")
    assert word.destroy
    assert_not Word.exists?(word.id)
  end

  # --- PaperTrail versioning ---

  test "creating a word does not create a version" do
    word = Word.create!(title: "No Version On Create")
    assert_equal 0, word.versions.count
  end

  test "updating a word creates a version" do
    word = words(:one)
    assert_difference "word.versions.count", 1 do
      word.update!(title: "MyString Updated")
    end
  end

  test "destroying a word creates a version" do
    word = Word.create!(title: "Word To Destroy")
    assert_difference "PaperTrail::Version.count", 1 do
      word.destroy!
    end
  end

  test "a no-op update does not create a version" do
    word = words(:one)
    assert_no_difference "word.versions.count" do
      word.update!(title: word.title)
    end
  end

  # --- tagging ---

  test "tag_list reflects tags assigned via fixtures" do
    word = words(:one)
    assert_equal %w[Very\ good Bad], word.tag_list
  end

  test "tag_list can be reassigned and saved" do
    word = Word.create!(title: "Taggable Word")
    word.update!(tag_list: "alpha, beta")
    word.reload
    assert_equal %w[alpha beta], word.tag_list
  end

  test "active_tags returns taggable_on tags up to the limit" do
    tags = Word.active_tags(2)
    assert_equal 2, tags.length
    assert tags.all? { |t| t.is_a?(ActsAsTaggableOn::Tag) }
  end

  # --- scopes ---

  test "body_contains finds words whose rich text body matches the query" do
    word = Word.create!(title: "Searchable Word")
    word.body = "This body mentions unicornsearch somewhere"
    word.save!

    results = Word.body_contains("unicornsearch")
    assert_includes results, word
  end

  test "body_contains returns all records when query is blank" do
    assert_equal Word.all.to_a.sort_by(&:id), Word.body_contains("").to_a.sort_by(&:id)
  end

  test "title_or_body_contains matches on title" do
    results = Word.title_or_body_contains("MyString_Two")
    assert_includes results, words(:two)
  end

  test "title_or_body_contains matches on body" do
    word = Word.create!(title: "Another Searchable Word")
    word.body = "contains needlephrase inside"
    word.save!

    results = Word.title_or_body_contains("needlephrase")
    assert_includes results, word
  end

  test "title_or_body_contains returns all when query is blank" do
    assert_equal Word.count, Word.title_or_body_contains("").to_a.uniq.count
  end

  test "has_content only returns words with a non-blank rich text body" do
    assert_includes Word.has_content, words(:one)
    assert_not_includes Word.has_content, words(:two)
  end

  test "empty_content only returns words without a rich text body" do
    assert_includes Word.empty_content, words(:two)
    assert_not_includes Word.empty_content, words(:one)
  end

  # --- recently_edited / recent_words ---

  test "recently_edited orders by updated_at desc and limits using Option" do
    # options fixture sets list_size_of_recent_words_parts to 5
    older = Word.create!(title: "Older Recently Edited")
    older.update_column(:updated_at, 2.days.ago)
    newer = Word.create!(title: "Newer Recently Edited")
    newer.update_column(:updated_at, 1.minute.ago)

    result = Word.recently_edited
    assert result.size <= 5
    assert_operator result.to_a.index(newer), :<, result.to_a.index(older)
  end

  test "recently_edited respects an explicit limit" do
    assert_equal 1, Word.recently_edited(1).size
  end

  test "recently_edited returns none for a zero or negative limit" do
    assert_equal 0, Word.recently_edited(0).size
    assert_equal 0, Word.recently_edited(-1).size
  end

  test "recent_words limits and orders by updated_at desc" do
    result = Word.recent_words(1)
    assert_equal 1, result.size
    assert_equal Word.order(updated_at: :desc).first, result.first
  end

  # --- ransack whitelisting ---

  test "ransackable_attributes whitelists expected columns" do
    assert_equal %w[title created_at updated_at], Word.ransackable_attributes
  end

  test "ransackable_associations whitelists expected associations" do
    assert_equal %w[activities base_tags rich_text_body tag_taggings taggings tags versions].sort,
                 Word.ransackable_associations.sort
  end

  test "ransackable_scopes whitelists the search scopes" do
    assert_equal [:body_contains, :title_or_body_contains], Word.ransackable_scopes
  end
end
