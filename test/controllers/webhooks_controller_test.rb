require 'test_helper'

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users( :john ) 
    sign_in(@user)

    @webhook = webhooks(:one)
  end

  test "should get index" do
    get webhooks_url
    assert_response :success
  end

  test "should get new" do
    get new_webhook_url
    assert_response :success
  end

  test "should create webhook" do
    assert_difference('Webhook.count') do
      post webhooks_url, params: { webhook: { title: @webhook.title, url: @webhook.url } }
    end

    assert_redirected_to webhooks_url
  end

  test "should get edit" do
    get edit_webhook_url(@webhook)
    assert_response :success
  end

  test "should update webhook" do
    patch webhook_url(@webhook), params: { webhook: { title: @webhook.title, url: @webhook.url } }
    assert_redirected_to webhooks_url
  end

  test "should destroy webhook" do
    assert_difference('Webhook.count', -1) do
      delete webhook_url(@webhook)
    end

    assert_redirected_to webhooks_url
  end
end
