class Option < ApplicationRecord
  include RegistrationToken

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
