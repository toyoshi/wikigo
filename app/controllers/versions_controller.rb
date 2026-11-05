class VersionsController < ApplicationController
  before_action :authenticate_user!, only: [:rollback]
  before_action :set_word, only: [:show, :rollback]

  def rollback
    version = @word.versions.find(params[:id])
    snapshot = version.reify

    # has_rich_text associations do not reify (the body lives in a separate
    # table), so restore it from the snapshot captured when the version was
    # saved. The update spins a new version, keeping the rollback itself
    # undoable. Without this the latest body would silently win (#82).
    @word.update!(title: snapshot.title, body: snapshot.body_snapshot)

    redirect_to word_path(@word), notice: 'Restored the selected version.'
  end

  def show
    @versions = @word.versions.reverse
    # params[:id] == 0 means to show diff with current_version 
    # (Paper Trail dose not keep current version)
    @version = (params[:id] == '0') ? @word : @word.versions.find(params[:id]).reify
  end

  private
  def set_word
    @word = Word.find(params[:word_id])
  end
end
