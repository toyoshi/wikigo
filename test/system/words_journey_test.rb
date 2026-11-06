require 'test_helper'

# The reference app's system-test exemplar.
#
# These run against the rack_test driver (no browser needed): they cover the
# journeys a real browser adds nothing to — navigation, search, a form round
# trip, and (since #110) the sign-in form itself. Anything that needs the
# Trix/JS editor belongs in a js_driver-capable suite, not here; keep
# rack_test tests honest about that.
class WordsJourneyTest < ActionDispatch::SystemTestCase
  driven_by :rack_test

  setup do
    # The root route lands on words#show id: 1 — in development that is the
    # seeded Main Page, but fixture ids are deterministic hashes, not 1. The
    # landing row is therefore part of the journey's stage, stated outright.
    @landing = Word.find_by(id: 1) ||
      Word.new(title: 'Landing Page', body: 'Landing Body Text', id: 1).tap do |word|
        word.save! # the rich-text writer populates the plain-text/snapshot columns too
      end
  end

  test "reader browses the wiki and finds pages through search" do
    visit root_path
    assert_text "Landing Body Text"

    visit words_path + "?q%5Btitle_or_body_contains%5D=MyString_Two"
    assert_text "MyString_Two"
  end

  test "visitor signs in through the form and renames a page" do
    visit new_user_session_path
    fill_in "Username or email", with: "john"
    fill_in "Password", with: "password"
    click_button "Log in"

    # Sign-in is a real round trip over the Session cookie, not a test-only
    # injection: after it the editor journey proceeds authenticated.
    assert_text "Sign out"

    visit word_path(words(:two))
    click_link "Edit"

    fill_in "Title", with: "Renamed Page"
    click_button "Update Word"

    assert_selector "h1", text: "Renamed Page"
  end
end
