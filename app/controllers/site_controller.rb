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
    Zip::File.open(params['archive'].tempfile) do |zip_file|
      zip_file.each do |entry|
        _, file_header, file_body = entry.get_input_stream.read.force_encoding('utf-8').split('---')

        header = YAML.load(file_header)
        body = file_body.is_a?(Array) ? file_body.join('---') : file_body

        w = Word.find_or_create_by({title: header[:title]})
        w.tag_list = header[:tags]
        w.body = body
        w.save
        binding.pry
      end
    end
    redirect_to site_settings_path, notice: 'Import completed'
  end
end
