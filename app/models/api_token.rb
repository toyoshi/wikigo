class ApiToken < ApplicationRecord
  belongs_to :user
  
  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :token_digest, presence: true, uniqueness: true
  
  
  # Generate a new API token and return the plain token
  def self.create_for_user(user, name)
    token = new(user: user, name: name)
    plain_token = token.send(:generate_plain_token)
    token.token_digest = Digest::SHA256.hexdigest(plain_token)
    token.save!
    [token, plain_token]
  end
  
  # Find token by plain token
  def self.find_by_token(plain_token)
    return nil if plain_token.blank?
    
    # Hash the plain token to compare with stored digest
    token_digest = Digest::SHA256.hexdigest(plain_token)
    find_by(token_digest: token_digest)
  end
  
  # Update last used timestamp
  def touch_last_used!
    update_column(:last_used_at, Time.current)
  end
  
  # Check if token is expired (optional, can be used for future expiration logic)
  def expired?
    false # No expiration for now
  end
  
  private
  
  def generate_token
    @plain_token = generate_plain_token
    self.token_digest = Digest::SHA256.hexdigest(@plain_token)
  end
  
  def generate_plain_token
    # Generate a 32-character random token
    SecureRandom.hex(32)
  end
end