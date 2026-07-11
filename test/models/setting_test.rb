require 'test_helper'

class SettingTest < ActiveSupport::TestCase
  test "exposes an accessor for every known Option key" do
    setting = Setting.new
    Option.keys.each do |key|
      assert_respond_to setting, key
      assert_respond_to setting, "#{key}="
    end
  end

  test "exposes an accessor for openai_api_key even if not an Option yet" do
    setting = Setting.new
    assert_respond_to setting, :openai_api_key
    assert_respond_to setting, :openai_api_key=
  end

  test "can be initialized with attributes like a plain ActiveModel" do
    setting = Setting.new(openai_api_key: "sk-test")
    assert_equal "sk-test", setting.openai_api_key
  end

  test "getters and setters simply hold in-memory values" do
    setting = Setting.new
    setting.openai_api_key = "sk-abc"
    assert_equal "sk-abc", setting.openai_api_key
  end
end
