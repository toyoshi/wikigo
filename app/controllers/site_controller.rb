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
    @setting = Setting.new( 
                           site_title: Option.site_title,
                           list_size_of_recent_words_parts: Option.list_size_of_recent_words_parts,
                          )
  end

  def update_settings
    Option.site_title = params[:setting][:site_title]
    Option.list_size_of_recent_words_parts = params[:setting][:list_size_of_recent_words_parts]
    redirect_to site_settings_path, notice: 'Setting updated'
  end
end
