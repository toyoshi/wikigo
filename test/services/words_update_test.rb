require 'test_helper'

class WordsUpdateTest < ActiveSupport::TestCase
  setup do
    @john = users(:john)
    @bob = users(:bob)
    @word = Word.first
    Webhook.delete_all # avoid sending webhooks from the update service
  end

  test "records an activity for users who favorited the word" do
    @word.favorites.find_or_create_by(user: @bob)

    assert_difference('PublicActivity::Activity.count', 1) do
      Words::Update.new(@john, @word.to_param, { body: 'updated' }).call
    end

    activity = PublicActivity::Activity.last
    assert_equal @john, activity.owner
    assert_equal @bob, activity.recipient
    assert_equal @word, activity.trackable
  end

  test "does not record an activity for the editor's own favorite" do
    @word.favorites.find_or_create_by(user: @john)

    assert_no_difference('PublicActivity::Activity.count') do
      Words::Update.new(@john, @word.to_param, { body: 'updated' }).call
    end
  end
end
