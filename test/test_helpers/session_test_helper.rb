module SessionTestHelper
  def sign_in_as(user)
    Current.session = user.sessions.create!

    ActionDispatch::TestRequest.create.cookie_jar.tap do |cookie_jar|
      cookie_jar.signed[:session_id] = Current.session.id
      cookies["session_id"] = cookie_jar[:session_id]
    end
  end

  # #110 compatibility: this suite's controller tests call sign_in(user).
  alias_method :sign_in, :sign_in_as

  def sign_out
    Current.session&.destroy!
    cookies.delete("session_id")
  end
end

# Mixed into every integration test when ActionDispatch::IntegrationTest
# loads. This build defines the class lazily (action_dispatch/testing/
# integration.rb), so registration via the load hook is the supported path —
# the key is that test_helper.rb requires this file before any test class is
# defined (the generator's output does not reach test/test_helpers on its
# own; nothing autoloads that directory here).
ActiveSupport.on_load(:action_dispatch_integration_test) do
  include SessionTestHelper
end
