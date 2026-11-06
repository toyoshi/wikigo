require 'test_helper'

# The reference app's system-test exemplar.
#
# These run against the rack_test driver (no browser needed): they cover the
# journeys a real browser adds nothing to — navigation, search, and a form
# round trip. Anything that needs the Trix/JS editor belongs in a
# js_driver-capable suite, not here; keep rack_test tests honest about that.
class WordsJourneyTest < ActionDispatch::SystemTestCase
  include Devise::Test::IntegrationHelpers

  # The default driven_by is :selenium; this app's system suite deliberately
  # stays browser-free (rack_test), so the CI step needs no driver setup.
  driven_by :rack_test

  test "reader browses the wiki and finds pages through search" do
    visit root_path
    assert_text "MyText"

    visit words_path + "?q%5Btitle_or_body_contains%5D=MyString_Two"
    assert_text "MyString_Two"
  end

  test "signed-in editor renames a page and sees the new title" do
    sign_in users(:john)

    visit word_path(words(:two))
    click_link "Edit"

    fill_in "Title", with: "Renamed Page"
    click_button "Update Word"

    assert_selector "h1", text: "Renamed Page"
  end
end
