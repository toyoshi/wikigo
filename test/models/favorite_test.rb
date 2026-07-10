require 'test_helper'

class FavoriteTest < ActiveSupport::TestCase
  test "invalid without a user" do
    favorite = Favorite.new(favable: words(:one), user: nil)
    assert_not favorite.valid?
    assert_includes favorite.errors[:user], "must exist"
  end

  test "invalid without a favable" do
    favorite = Favorite.new(favable: nil, user: users(:john))
    assert_not favorite.valid?
    assert_includes favorite.errors[:favable], "must exist"
  end

  test "valid with a user and a polymorphic favable" do
    favorite = Favorite.new(favable: words(:one), user: users(:john))
    assert favorite.valid?
  end

  test "can be created for a Word via acts_as_favable" do
    word = words(:two)
    user = users(:bob)

    favorite = Favorite.create!(favable: word, user: user)

    assert_includes word.favorites, favorite
    assert_includes Word.find_favorites_for(word), favorite
    assert_includes Word.find_favorites_by_user(user), favorite
  end

  test "add_favorite appends a favorite through the favable association" do
    word = words(:one)
    user = users(:bob)
    favorite = Favorite.new(user: user)

    word.add_favorite(favorite)

    assert favorite.persisted?
    assert_equal word.id, favorite.favable_id
    assert_equal "Word", favorite.favable_type
  end

  test "find_favorites_by_user scopes to the given user" do
    john_favorite = Favorite.create!(favable: words(:one), user: users(:john))
    Favorite.create!(favable: words(:two), user: users(:bob))

    results = Favorite.find_favorites_by_user(users(:john))
    assert_equal [john_favorite], results.to_a
  end

  test "default scope orders favorites by created_at ascending" do
    older = Favorite.create!(favable: words(:one), user: users(:john), created_at: 2.days.ago)
    newer = Favorite.create!(favable: words(:two), user: users(:bob), created_at: 1.day.ago)

    assert_equal [older, newer], Favorite.all.to_a
  end
end
