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
    export_path = Rails.root.join('tmp') # for Heroku https://devcenter.heroku.com/articles/cedar-migration


    zipfile_name = Tempfile.new('export-', temp_dir)

    Zip::File.open(zipfile_name.path, Zip::File::CREATE) do |zipfile|
      Word.all.find_in_batches do |batch|
        batch.each do |w|
          temp_file = Tempfile.new('md-', temp_dir)
          temp_file.puts w.to_middleman
          zipfile.add("#{w.title}_#{w.id}.md", temp_file.path)
          temp_file.close
        end
      end
    end

    send_file(zipfile_name, filename: 'export.zip')
    return
  end

  private 

  def temp_dir
    path = Rails.root.join('tmp')
    Dir.mkdir(path) unless Dir.exists?(path)
    path
  end
end
