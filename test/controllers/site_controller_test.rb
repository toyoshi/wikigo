require 'test_helper'
require 'zip'

class SiteControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users( :john ) 
    sign_in(@user)
  end

  test "should get members" do
    get site_members_url
    assert_response :success
  end

  test "update user role" do
    @user2 = users( :bob )
    old_role = @user2.role
    put update_user_role_url, params: { user: {id: @user2.id, role: 'admin' }}
    assert_not_equal old_role, @user2.reload.role
  end

  test "AdminでなくてはSite Settingのページにアクセスできない" do
    @user2 = users( :bob )
    sign_in(@user2)
    assert_raises do
      get site_settings_url
    end
  end

  test "shoud get export and download" do
    get site_export_url
    assert_equal 'export.zip', response.header["Content-Disposition"].match("filename=\"(.*.zip)\"")[1]
  end

  test "should import words from zip file" do
    # Delete existing word if any
    Word.where(title: "Test Import Word").destroy_all
    
    # Create a temporary zip file with word data
    zip_file = Tempfile.new(['test_import', '.zip'])
    begin
      Zip::OutputStream.open(zip_file.path) do |z|
        z.put_next_entry("test_word.html")
        content = <<~EOS
---
title: Test Import Word
date: 2024-01-01 10:00:00
tags: test, import
wiki:word_id: 999
---

<p>This is test content</p>
EOS
        z.print content
      end

      # Count words before import
      word_count_before = Word.count

      # Upload the zip file
      zip_file.rewind
      post site_import_url, params: { 
        archive: Rack::Test::UploadedFile.new(zip_file.path, 'application/zip')
      }

      assert_redirected_to site_settings_path
      
      # Don't follow redirect to avoid settings page error
      assert_match /Import completed: 1 words imported/, flash[:notice]

      # Verify the word was imported
      assert_equal word_count_before + 1, Word.count
      imported_word = Word.find_by(title: "Test Import Word")
      assert_not_nil imported_word
      assert_equal ["import", "test"], imported_word.tag_list.sort
      assert_match /This is test content/, imported_word.body.to_s
    ensure
      zip_file.close
      zip_file.unlink
    end
  end

  test "should handle import without file" do
    post site_import_url
    assert_redirected_to site_settings_path
    assert_equal 'Please select a file to import', flash[:alert]
  end

  test "should handle import with invalid zip" do
    invalid_file = Tempfile.new(['invalid', '.txt'])
    begin
      invalid_file.write("This is not a zip file")
      invalid_file.rewind

      post site_import_url, params: { 
        archive: Rack::Test::UploadedFile.new(invalid_file.path, 'text/plain')
      }

      assert_redirected_to site_settings_path
      assert_match /Import failed:/, flash[:alert]
    ensure
      invalid_file.close
      invalid_file.unlink
    end
  end
end
