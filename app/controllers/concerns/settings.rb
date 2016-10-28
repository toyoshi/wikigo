concern :Settings do
  included do
    def settings
      @setting = Setting.new( Option.all_with_hash )
    end

    def update_settings
      Option.update_all(params[:setting])
      redirect_to site_settings_path, notice: 'Setting updated'
    end
  end
end
