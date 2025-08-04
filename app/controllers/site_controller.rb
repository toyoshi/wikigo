require 'zip'

class SiteController < ApplicationController
  include Settings

  before_action :authenticate_user!
  before_action :authenthicate_admin!, except: [:members, :activities]

  def members
    @key = Option.user_registration_token
    @users = User.all
  end

  def update_user_role
    @user = User.find(params[:user][:id])
    @user.send("#{params[:user][:role]}!")
    redirect_to site_members_path, notice: 'Role updated'
  end

  def regenerate_token
    Option.update_registration_token
    redirect_to site_members_path, notice: 'Token regenerated'
  end

  def activities
    @activities = PublicActivity::Activity.where(recipient: current_user).order('created_at desc').limit(100)
  end

  def export
    zip_path = Words::Export.new.call
    send_file(zip_path, filename: 'export.zip')
  end

  def import
    unless params['archive'].present?
      redirect_to site_settings_path, alert: 'Please select a file to import'
      return
    end

    begin
      imported_count = 0
      failed_count = 0
      
      Zip::File.open(params['archive'].tempfile) do |zip_file|
        zip_file.each do |entry|
          content = entry.get_input_stream.read.force_encoding('utf-8')
          
          # Split by --- and handle the format properly
          parts = content.split('---', 3)
          
          # Skip if not enough parts
          if parts.length < 3
            failed_count += 1
            next
          end
          
          # The YAML header is the second part (first is empty)
          file_header = parts[1]
          file_body = parts[2]

          header = YAML.safe_load(file_header, permitted_classes: [Date, Time, DateTime])
          
          # Use string keys instead of symbols
          title = header['title'] || header[:title]
          tags = header['tags'] || header[:tags]
          
          unless title
            failed_count += 1
            next
          end

          w = Word.find_or_create_by(title: title)
          w.tag_list = tags if tags
          w.body = file_body.strip if file_body
          
          if w.save
            imported_count += 1
          else
            failed_count += 1
          end
        end
      end
      
      message = "Import completed: #{imported_count} words imported"
      message += ", #{failed_count} failed" if failed_count > 0
      
      redirect_to site_settings_path, notice: message
    rescue => e
      redirect_to site_settings_path, alert: "Import failed: #{e.message}"
    end
  end

  def reset_content
    begin
      # Delete all tags first
      tags_count = ActsAsTaggableOn::Tag.count
      ActsAsTaggableOn::Tag.destroy_all
      
      # Delete all words except Main Page and Side Bar
      protected_titles = ['Main Page', 'Side Bar']
      deleted_count = Word.where.not(title: protected_titles).destroy_all.count
      
      # Reset Main Page and Side Bar to default content
      main_page = Word.find_by(title: 'Main Page')
      if main_page
        main_page.update(body: "Wiki wiki go!", tag_list: [])
      end
      
      side_bar = Word.find_by(title: 'Side Bar')
      if side_bar
        side_bar.update(body: "--- menu ---", tag_list: [])
      end
      
      redirect_to site_settings_path, notice: "Content reset completed: #{deleted_count} words and #{tags_count} tags deleted. Main Page and Side Bar reset to defaults."
    rescue => e
      redirect_to site_settings_path, alert: "Failed to reset content: #{e.message}"
    end
  end
  
end
