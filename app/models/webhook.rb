class Webhook < ApplicationRecord
  validates :url, presence: true
end

