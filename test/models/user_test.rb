require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "User default role" do
    @user = users( :john ) 
    assert_equal false, @user.admin?
  end
end
