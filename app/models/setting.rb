class Setting
  include ActiveModel::Model

  Option.keys.each do |p|
    attr_accessor p
  end
  
  # Add API key accessor separately
  attr_accessor :openai_api_key
  
end
