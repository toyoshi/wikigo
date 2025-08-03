class Word < ApplicationRecord
  acts_as_taggable
  acts_as_favable
  has_rich_text :body

  include PublicActivity::Model
  include TagFinder
  include TitleConverter
  has_paper_trail on: [:update, :destroy]

  validates :title, presence: true
  validates :title, uniqueness: true
  
  # Prevent deletion of the home page (ID=1)
  before_destroy :prevent_home_page_deletion

  def self.ransackable_attributes(auth_object = nil)
    %w[title created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[activities base_tags rich_text_body tag_taggings taggings tags versions]
  end

  def self.ransackable_scopes(auth_object = nil)
    [:body_contains, :title_or_body_contains]
  end

  # Custom scope for searching ActionText content
  scope :body_contains, ->(query) {
    return all if query.blank?
    joins(:rich_text_body)
      .where("action_text_rich_texts.body LIKE ?", "%#{sanitize_sql_like(query)}%")
  }

  # Custom scope for searching title or body
  scope :title_or_body_contains, ->(query) {
    return all if query.blank?
    escaped_query = "%#{sanitize_sql_like(query)}%"
    
    left_outer_joins(:rich_text_body)
      .where(
        "words.title LIKE :query OR action_text_rich_texts.body LIKE :query",
        query: escaped_query
      )
      .distinct
  }

  def self.find(input)
    if input.is_a?(Integer)
      super
    else
      find_by_title(self.param_to_title(input))
    end
  end

  def self.recently_edited(limit = nil)
    limit ||= Option.list_size_of_recent_words_parts&.to_i || 10
    return none if limit <= 0
    order(updated_at: :desc).limit(limit)
  end

  def to_param
    title_to_param
  end

  def self.recent_words(num)
    Word.all.limit(num).order('updated_at desc')
  end

  def to_middleman
    <<"EOS"
---
title: #{self.title}
date: #{self.created_at}
tags: #{self.tag_list}
wiki:word_id: #{self.id}
---

#{self.body}
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
