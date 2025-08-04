concern :Settings do
  included do
    def settings
      settings_hash = Option.all_with_hash
      # Add API key if it exists (masked for security)
      if Option.openai_api_key.present?
        settings_hash['openai_api_key'] = '••••••••' # Mask the key in the form
      end
      @setting = Setting.new(settings_hash)
    end

    def update_settings
      setting_params = params[:setting]
      
      # Handle password fields - don't update if empty
      if setting_params[:openai_api_key].present?
        Option.openai_api_key = setting_params[:openai_api_key]
        setting_params.delete(:openai_api_key)
      end
      
      # Update other settings
      Option.update_all(setting_params)
      redirect_to site_settings_path, notice: 'Setting updated'
    end
  end
end
