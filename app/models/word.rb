class Word < ApplicationRecord
  # === Plugins / rich content ===
  acts_as_taggable
  acts_as_favable
  has_rich_text :body

  include PublicActivity::Model
  include TagFinder
  include TitleConverter
  has_paper_trail on: [:update, :destroy]

  # === Validations ===
  validates :title, presence: true
  validates :title, uniqueness: true

  # === Callbacks ===
  # Prevent deletion of the home page (ID=1)
  before_destroy :prevent_home_page_deletion

  # === Scopes ===
  # Search ActionText content only.
  scope :body_contains, ->(query) {
    return all if query.blank?
    joins(:rich_text_body)
      .where("action_text_rich_texts.body LIKE ? ESCAPE '\\'", "%#{sanitize_sql_like(query)}%")
  }

  # Search title or ActionText content.
  scope :title_or_body_contains, ->(query) {
    return all if query.blank?
    escaped_query = "%#{sanitize_sql_like(query)}%"

    left_outer_joins(:rich_text_body)
      .where(
        "words.title LIKE :query ESCAPE '\\' OR action_text_rich_texts.body LIKE :query ESCAPE '\\'",
        query: escaped_query
      )
      .distinct
  }

  # Words that have a non-empty body.
  scope :has_content, -> {
    joins(:rich_text_body)
      .where.not(action_text_rich_texts: { body: [nil, ''] })
      .distinct
  }

  # Words with no body (missing or empty rich text).
  scope :empty_content, -> {
    left_outer_joins(:rich_text_body)
      .where(action_text_rich_texts: { body: [nil, ''] })
      .or(left_outer_joins(:rich_text_body).where(action_text_rich_texts: { id: nil }))
      .distinct
  }

  # === Ransack allow-lists ===
  def self.ransackable_attributes(auth_object = nil)
    %w[title created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[activities base_tags rich_text_body tag_taggings taggings tags versions]
  end

  def self.ransackable_scopes(auth_object = nil)
    [:body_contains, :title_or_body_contains]
  end

  # === Class methods ===
  # Look up by numeric id, or by title when given a slug/string.
  def self.find(input)
    if input.is_a?(Integer)
      super
    else
      find_by_title(param_to_title(input))
    end
  end

  def self.recently_edited(limit = nil)
    limit ||= Option.list_size_of_recent_words_parts&.to_i || 10
    return none if limit <= 0
    order(updated_at: :desc).limit(limit)
  end

  def self.recent_words(num)
    all.limit(num).order(updated_at: :desc)
  end

  # === Instance methods ===
  def to_param
    title_to_param
  end

  # Serialize to Middleman-flavored Markdown with YAML front matter.
  def to_middleman
    <<"EOS"
---
title: #{title}
date: #{created_at}
tags: #{tag_list}
wiki:word_id: #{id}
---

#{body.to_s}
EOS
  end

  private

  def prevent_home_page_deletion
    if id == 1
      errors.add(:base, "ホームページ（ID=1）は削除できません")
      throw(:abort)
    end
  end
end
