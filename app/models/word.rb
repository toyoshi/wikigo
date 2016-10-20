class Word < ApplicationRecord
  include TitleConverter
  has_paper_trail on: [:update, :destroy]

  validates :title, presence: true

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
    Word.all.limit(num).order('created_at desc')
  end
end
