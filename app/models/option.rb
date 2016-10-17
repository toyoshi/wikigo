class Option < ApplicationRecord
  def self.get(key)
    self.find_by_option_key(key).option_value
  end

  def self.update_registration_token
    registration_token = find_by_option_key(:USER_REGISTRATION_TOKEN)
    registration_token.update( option_value: SecureRandom.uuid.gsub!(/-/,''))
  end
end
