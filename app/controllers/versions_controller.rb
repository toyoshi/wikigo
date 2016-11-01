class VersionsController < ApplicationController
  before_action :authenticate_user!, only: [:rollback]
  before_action :set_word, only: [:show, :rollback, :index, :destroy]

  def rollback
    word = @version
    word.save
    redirect_to word_path(word)
  end

  def show
    # params[:id] == 0 means to show diff with current_version 
    # (Paper Trail dose not keep current version)
    @version = (params[:id] == '0') ? @word : @word.versions.find(params[:id]).reify
  end

  def index
    @versions = @word.versions.reverse
  end

  private
  def set_word
    @word = Word.find(params[:word_id])
  end
end
