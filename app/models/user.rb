class User < ApplicationRecord
  after_save :keep_admin_exist
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  enum :role, { editor: 0, admin: 99 }
  
  has_many :api_tokens, dependent: :destroy

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login

  validates :username, presence: true, uniqueness: { :case_sensitive => false }, length: { in: 3..255 }
  validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, multiline: true

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_hash).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
      where(conditions.to_hash).first
    end
  end
  
  # Generate a new API token for this user
  def generate_api_token(name = "Default API Key")
    # Remove existing token with same name
    api_tokens.where(name: name).destroy_all
    
    # If name is Default API Key and already exists, make it unique
    if name == "Default API Key" && api_tokens.where("name LIKE ?", "Default API Key%").exists?
      counter = api_tokens.where("name LIKE ?", "Default API Key%").count + 1
      name = "Default API Key #{counter}"
    end
    
    # Create new token
    ApiToken.create_for_user(self, name)
  end
  
  # Get the current API token (assumes one token per user for now)
  def current_api_token
    api_tokens.first
  end

  private

  def keep_admin_exist
    self.admin! if User.admin.count == 0
  end
end
