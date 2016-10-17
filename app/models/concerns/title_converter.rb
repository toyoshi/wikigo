concern :TitleConverter do
  included do
    def title_to_param
      title.gsub(' ', '-')
    end

    def self.param_to_title(str)
      str.gsub('-', ' ')
    end
  end
end
