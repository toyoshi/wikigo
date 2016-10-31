class VersionsController < ApplicationController
  before_action :set_word, only: [:show, :rollback, :index, :destroy]

  def rollback
    @word.save
    redirect_to word_path(@word)
  end

  def show
  end

  def index
    @versions = @word.versions.reverse
  end

  private
  def set_word
    @word = Word.find(params[:word_id])
    if params[:id]
      @word = @word.versions.find(params[:id]).reify
    end
  end
end
