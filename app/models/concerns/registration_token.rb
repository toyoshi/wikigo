concern :RegistrationToken do
  included do
    def self.update_registration_token
      self.user_registration_token = SecureRandom.uuid.gsub!(/-/,'')
    end
  end
end
