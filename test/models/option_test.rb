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
end
