require 'test_helper'

class SettingTest < ActiveSupport::TestCase
  test "exposes an accessor for every known Option key" do
    setting = Setting.new
    Option.known_keys.each do |key|
      assert_respond_to setting, key
      assert_respond_to setting, "#{key}="
    end
  end

  test "exposes typed string attributes mirroring the Option registry" do
    setting = Setting.new(theme: "solarized")
    assert_equal "solarized", setting.theme
    assert_equal "WikiGo", Setting.new.site_title # registry default rides along
  end
end
