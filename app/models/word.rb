class Word < ApplicationRecord
  acts_as_taggable
  # acts_as_favable # TODO: Check Rails 8 compatibility issue
  has_rich_text :body

  include PublicActivity::Model
  include TagFinder
  include TitleConverter
  has_paper_trail on: [:update, :destroy]

  validates :title, presence: true
  validates :title, uniqueness: true

  def self.ransackable_attributes(auth_object = nil)
    %w[title body created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[activities base_tags rich_text_body tag_taggings taggings tags versions]
  end

  def self.find(input)
    if input.is_a?(Integer)
      super
    else
      find_by_title(self.param_to_title(input))
    end
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
end
