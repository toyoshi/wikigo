class Word < ApplicationRecord
  has_paper_trail on: [:update, :destroy]
  paginates_per 2

  def self.find(input)
    if input.is_a?(Integer)
      super
    else
      find_by_title(input)
    end
  end

  def to_param
    title
  end
end
