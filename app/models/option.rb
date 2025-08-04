class Option < ApplicationRecord
  include RegistrationToken

  def self.keys
    self.all.map do |v|
      v.option_key
    end
  end

  def self.all_with_hash
    Hash[
      self.all.map do |v|
        [v.option_key, v.option_value]
      end
    ]
  end

  def self.update_all(options)
    options.each do |k, v|
      self.send("#{k}=", v)
    end
  end

  ## Optionをハッシュのように扱うためのメソッド
  def self.method_missing(method, *args)
    attribute = method.to_s
    if attribute =~ /=$/
      column = attribute[0, attribute.size - 1]
      o = self.find_or_initialize_by(option_key: column)
      o.option_value = args.first.to_s
      o.save
    else
      o = self.find_or_initialize_by(option_key: method.to_s)
      o.option_value
    end
  end
end
