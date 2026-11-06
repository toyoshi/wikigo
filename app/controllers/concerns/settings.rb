concern :Settings do
  included do
    def settings
      @setting = Setting.new( Option.all_with_hash )
    end

    def update_settings
      # The form posts its own commit button; trim to the registry at the
      # HTTP boundary so junk keys cannot reach the model. Option.update_all
      # stays strict for programmatic callers.
      Option.update_all(params.require(:setting).permit(Option.known_keys).to_h)
      redirect_to site_settings_path, notice: 'Setting updated'
    end
  end
end
