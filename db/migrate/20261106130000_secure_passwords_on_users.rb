class SecurePasswordsOnUsers < ActiveRecord::Migration[8.0]
  def up
    # Devise -> Rails 8 authentication generator (#110).
    #
    # has_secure_password stores a BCrypt digest in password_digest; the
    # password-reset token pair replaces Devise's recoverable columns.
    add_column :users, :password_digest, :string
    add_column :users, :password_reset_token, :string
    add_column :users, :password_reset_sent_at, :datetime

    # Devise's database_authenticatable column is BCrypt too, so existing
    # digests carry over verbatim — nobody is locked out by the migration.
    execute "UPDATE users SET password_digest = encrypted_password"

    # Sign-in tracking columns are superseded by the sessions table
    # (Session records user_agent + ip_address per sign-in).
    remove_column :users, :encrypted_password
    remove_column :users, :reset_password_token
    remove_column :users, :reset_password_sent_at
    remove_column :users, :remember_created_at
    remove_column :users, :sign_in_count
    remove_column :users, :current_sign_in_at
    remove_column :users, :last_sign_in_at
    remove_column :users, :current_sign_in_ip
    remove_column :users, :last_sign_in_ip
  end

  def down
    add_column :users, :encrypted_password, :string, default: "", null: false
    execute "UPDATE users SET encrypted_password = password_digest"
    remove_column :users, :password_digest
    remove_column :users, :password_reset_token
    remove_column :users, :password_reset_sent_at
    add_column :users, :reset_password_token, :string
    add_column :users, :reset_password_sent_at, :datetime
    add_column :users, :remember_created_at, :datetime
    add_column :users, :sign_in_count, :integer, default: 0, null: false
    add_column :users, :current_sign_in_at, :datetime
    add_column :users, :last_sign_in_at, :datetime
    add_column :users, :current_sign_in_ip, :string
    add_column :users, :last_sign_in_ip, :string
  end
end
