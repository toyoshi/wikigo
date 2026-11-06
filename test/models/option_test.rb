require 'test_helper'

class OptionTest < ActiveSupport::TestCase
  test "Update registration token" do
    Option.update_registration_token #TODO: move to initializer
    current_token = Option.user_registration_token
    assert_not_equal current_token, Option.update_registration_token
  end

  test "known_keys returns the registry, not whatever rows happen to exist" do
    assert_includes Option.known_keys, 'site_title'
    assert_includes Option.known_keys, 'openai_api_key'
  end

  test "reading an unknown key fails loudly instead of magic" do
    assert_raises(NoMethodError) do
      Option.some_key_that_does_not_exist
    end
  end

  test "setting a known value creates or updates exactly one row" do
    Option.site_title = 'My Wiki'
    assert_equal 'My Wiki', Option.site_title

    Option.site_title = 'Renamed Wiki'
    assert_equal 'Renamed Wiki', Option.site_title
    assert_equal 1, Option.where(option_key: 'site_title').count
  end

  test "unknown writers are rejected" do
    assert_raises(NoMethodError) do
      Option.numeric_option = 42
    end
  end

  test "known values are always stored as strings" do
    Option.list_size_of_recent_words_parts = 42
    assert_equal '42', Option.list_size_of_recent_words_parts
  end

  test "all_with_hash builds a key/value hash of every option" do
    hash = Option.all_with_hash
    assert_equal "5", hash["list_size_of_recent_words_parts"]
  end

  test "update_all writes known options at once" do
    Option.update_all("list_size_of_recent_words_parts" => "9", "site_title" => "Bulk Title")

    assert_equal "9", Option.list_size_of_recent_words_parts
    assert_equal "Bulk Title", Option.site_title
  end

  test "update_all refuses unknown keys instead of persisting junk" do
    assert_raises(ArgumentError) do
      Option.update_all("new_key" => "value")
    end
    assert_equal 0, Option.where(option_key: "new_key").count
  end

  test "option values are encrypted at rest (#113)" do
    Option.openai_api_key = 'sk-super-secret-value'

    raw = ActiveRecord::Base.connection.select_value(
      "SELECT option_value FROM options WHERE option_key = 'openai_api_key'")

    assert_not_equal 'sk-super-secret-value', raw.to_s
    assert_not_includes raw.to_s, 'sk-super-secret-value'
    # Reads stay transparent through the model.
    assert_equal 'sk-super-secret-value', Option.openai_api_key
  end

  test "existing fixture value is readable" do
    assert_equal "5", Option.list_size_of_recent_words_parts
  end
end
