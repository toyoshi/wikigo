class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_global_word

  def set_global_word
    @menu = Word.find_or_create_by(title: '_menu')
  end
end
