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
    t = Tempfile.new('export-', temp_dir)

    Zip::OutputStream.open(t.path) do |z|
      Word.all.find_in_batches do |batch|
        batch.each do |w|
          z.put_next_entry("#{w.id}.md")
          z.print w.to_middleman
        end
      end
    end
    t.close

    send_file(t.path, filename: 'export.zip', length: File.size(t.path))
    return
  end

  private 

  def temp_dir
    path = Rails.root.join('tmp')
    Dir.mkdir(path) unless Dir.exists?(path)
    path
  end
end
