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

    result = Words::Import.new(params['archive']).call

    message = "Import completed: #{result.imported_count} words imported"
    message += ", #{result.failed_count} failed" if result.failed_count > 0

    redirect_to site_settings_path, notice: message
  rescue => e
    redirect_to site_settings_path, alert: "Import failed: #{e.message}"
  end

  def reset_content
    result = Words::ResetContent.new.call

    redirect_to site_settings_path, notice: "Content reset completed: #{result.deleted_count} words and #{result.tags_count} tags deleted. Main Page and Side Bar reset to defaults."
  rescue => e
    redirect_to site_settings_path, alert: "Failed to reset content: #{e.message}"
  end
end
