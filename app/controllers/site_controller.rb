class SiteController < ApplicationController
  before_action :authenticate_user!
  before_action :authenthicate_admin!, except: [:members]


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

  def settings
    @setting = Setting.new( site_title: Option.site_title )
  end

  def update_settings
    Option.site_title = params[:setting][:site_title]
    redirect_to site_settings_path, notice: 'Setting updated'
  end
end
