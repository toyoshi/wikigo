class Setting
  include ActiveModel::Model
  include ActiveModel::Attributes

  # Form object mirroring Option's explicit registry (see Option::KNOWN_KEYS),
  # so the settings form binds exactly the keys the model accepts.
  Option::KNOWN_KEYS.each do |key, default|
    attribute key, :string, default: default
  end
end
