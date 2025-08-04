class Setting
  include ActiveModel::Model

  Option.keys.each do |p|
    attr_accessor p
  end
  
  # Add attr_accessor for any keys that might not be in Option.keys yet
  attr_accessor :openai_api_key
  
end
