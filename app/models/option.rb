class Option < ApplicationRecord
  def self.get(key)
    self.find_by_option_key(key).option_value
  end
end
