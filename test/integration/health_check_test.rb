require 'test_helper'

class HealthCheckTest < ActionDispatch::IntegrationTest
  # GET /up is the contract deploy tooling depends on (Kamal's proxy,
  # container health checks, uptime monitors): a public, unauthenticated
  # 200 from Rails::HealthController (#111). The HTML render is the green
  # page; JSON carries the machine-readable status.
  test "up is public and renders the green page" do
    get "/up"
    assert_response :success
    assert_includes response.body, "green"
  end

  test "up reports status up as json" do
    get "/up", headers: { "accept" => "application/json" }
    assert_response :success
    assert_equal "up", JSON.parse(response.body)["status"]
  end
end
