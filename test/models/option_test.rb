require 'test_helper'

class OptionTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end

  test "Update registration token" do
    Option.update_registration_token #TODO: move to initializer
    current_token = Option.user_registration_token
    assert_not_equal current_token, Option.update_registration_token
  end

  test "keys returns the option_key of every stored option" do
    assert_equal ["list_size_of_recent_words_parts"], Option.keys
  end

  test "reading an unknown key returns the column default instead of raising" do
    # method_missing uses find_or_initialize_by, so an unset key yields an
    # unsaved record whose option_value falls back to the "" column default.
    assert_equal "", Option.some_key_that_does_not_exist
  end

  test "setting a value via method_missing creates or updates the option" do
    Option.site_title = "My Wiki"
    assert_equal "My Wiki", Option.site_title

    Option.site_title = "Renamed Wiki"
    assert_equal "Renamed Wiki", Option.site_title
    assert_equal 1, Option.where(option_key: "site_title").count
  end

  test "values are always returned as strings" do
    Option.numeric_option = 42
    assert_equal "42", Option.numeric_option
  end

  test "all_with_hash builds a key/value hash of every option" do
    hash = Option.all_with_hash
    assert_equal "5", hash["list_size_of_recent_words_parts"]
  end

  test "update_all writes multiple options at once" do
    Option.update_all("list_size_of_recent_words_parts" => "9", "new_key" => "value")

    assert_equal "9", Option.list_size_of_recent_words_parts
    assert_equal "value", Option.new_key
  end

  test "existing fixture value is readable" do
    assert_equal "5", Option.list_size_of_recent_words_parts
  end
end
