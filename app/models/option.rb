class Option < ApplicationRecord
  include RegistrationToken

  # At-rest encryption for every stored value (#113). The registry includes
  # secrets (openai_api_key today), and a value-level allow list would only
  # recreate the bug class this exists to prevent: one forgotten column name
  # silently stores a secret in the clear. Non-secret values ride along
  # happily; reads stay transparent.
  #
  # The encryptor derives its primary key from SECRET_KEY_BASE. To rotate,
  # add a previous key via config.active_record.encryptions.schemes or
  # key_rotation (ActiveRecord::Encryption) — old rows decrypt under the old
  # key and re-encrypt under the new one on next write.
  encrypts :option_value

  # Explicit registry of every known setting.
  #
  # This replaces a method_missing + send string dispatch that accepted any
  # key at runtime (#114). Referenced code must not dispatch on user input:
  # keys are declared here, values are stored as strings, and an unknown key
  # now fails loudly instead of silently reading an empty row.
  #
  # Each entry defines Option.<key> / Option.<key>= class methods returning
  # the stored value, falling back to the default below.
  KNOWN_KEYS = {
    'site_title' => 'WikiGo',
    'theme' => 'default',
    'show_recently_edited_items' => 'true',
    'list_size_of_recent_words_parts' => '10',
    'html_append_head' => '',
    'html_append_body' => '',
    'user_registration_token' => '',
    'openai_api_key' => '',
  }.freeze

  # @api public
  def self.known_keys
    KNOWN_KEYS.keys
  end

  KNOWN_KEYS.each do |key, default|
    define_singleton_method(key) do
      find_by(option_key: key)&.option_value || default
    end
    define_singleton_method("#{key}=") do |value|
      option = find_or_initialize_by(option_key: key)
      option.update!(option_value: value.to_s)
      option.option_value
    end
  end

  # Registry keys overlaid with whatever is persisted, so the settings form
  # always binds a complete set of values.
  #
  # @api public
  def self.all_with_hash
    stored = where(option_key: KNOWN_KEYS.keys).pluck(:option_key, :option_value).to_h
    KNOWN_KEYS.merge(stored)
  end

  # Bulk write used by the settings form. Unknown keys raise rather than
  # being silently persisted as junk rows.
  #
  # @api public
  def self.update_all(settings)
    unknown = settings.keys.map(&:to_s) - KNOWN_KEYS.keys
    raise ArgumentError, "unknown option(s): #{unknown.join(', ')}" if unknown.any?

    settings.each do |key, value|
      public_send("#{key}=", value)
    end
  end
end
