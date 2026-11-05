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
  # Keep the searchable / history snapshots of the ActionText body in sync.
  before_save :sync_body_snapshots
  # Prevent deletion of the home page (ID=1)
  before_destroy :prevent_home_page_deletion

  # === Scopes ===
  # Search the body content. Runs against body_plain_text (saved at write
  # time with HTML tags removed), so markup such as <strong> never leaks into
  # results and no rich-text join is required.
  scope :body_contains, ->(query) {
    return all if query.blank?
    where("words.body_plain_text LIKE ? ESCAPE '\\'", "%#{sanitize_sql_like(query)}%")
  }

  # Search title or body content. See body_contains for why this uses
  # body_plain_text rather than the raw rich-text HTML.
  scope :title_or_body_contains, ->(query) {
    return all if query.blank?
    escaped_query = "%#{sanitize_sql_like(query)}%"

    where(
      "words.title LIKE :query ESCAPE '\\' OR words.body_plain_text LIKE :query ESCAPE '\\'",
      query: escaped_query
    )
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
  # Raises ActiveRecord::RecordNotFound (404) when nothing matches.
  def self.find(input)
    if input.to_s.match?(/\A\d+\z/)
      super
    else
      word = find_by_title(param_to_title(input))
      word || raise(ActiveRecord::RecordNotFound, "Couldn't find Word with 'title' = #{param_to_title(input).inspect}")
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

  # Rails 8.1 Markdown rendering: render markdown: @word outputs this.
  def to_markdown
    "# #{title}\n\n#{body_plain_text.presence || body.try(:to_plain_text) || body.to_s}\n"
  end

  private

  # Copy the ActionText body into the plain-text and HTML snapshot columns.
  # * body_plain_text feeds the search scopes so HTML tags never match (#83).
  # * body_snapshot is serialized by PaperTrail so version history renders the
  #   body the record had at that time, since reify cannot restore has_rich_text
  #   associations (#82).
  #
  # The HTML comes from the content fragment rather than RichText#to_s, which
  # renders through the trix-content layout and would bake that markup into
  # the stored snapshot. Assign only when the value actually differs so a
  # no-op update stays a no-op (and does not spin a new PaperTrail version).
  def sync_body_snapshots
    rich_text = body
    plain = rich_text.try(:to_plain_text).to_s
    html = rich_text&.body&.fragment&.to_s.to_s
    self.body_plain_text = plain if body_plain_text != plain
    self.body_snapshot = html if body_snapshot != html
  end

  def prevent_home_page_deletion
    if id == 1
      errors.add(:base, "ホームページ（ID=1）は削除できません")
      throw(:abort)
    end
  end
end
