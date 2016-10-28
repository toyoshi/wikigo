class Setting
  include ActiveModel::Model

  Option.keys.each do |p|
    attr_accessor p
  end
  
end
