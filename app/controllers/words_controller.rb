class WordsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :tags, :tag]
  before_action :set_word, only: [:show, :version, :edit, :destroy]
  before_action :set_tags, only: [:new, :create, :edit, :update]

  # GET /words
  # GET /words.json
  def index
    @words = @search.result.order('updated_at desc').page(params[:page])
  end

  # GET /words/1
  # GET /words/1.json
  def show
  end

  def tags
    @tags = Word.tag_counts_on(:tags)
    respond_to do |format|
        format.html { render :tags }
    end
  end

  def tag
    @tag = params[:tag_list]
    @words = Word.tagged_with(@tag)
    respond_to do |format|
        format.html { render :tag }
    end
  end

  def version
    @word = @word.versions.find(params[:version]).reify
    respond_to do |format|
        format.html { render :show }
    end
  end

  # GET /words/new
  def new
    @word = Word.new
  end

  # GET /words/1/edit
  def edit
  end

  # POST /words
  # POST /words.json
  def create
    result = Words::Create.new(current_user, word_params).call
    @word = result.word

    respond_to do |format|
      if result.success?
        format.html { redirect_to @word, notice: 'Word was successfully created.' }
        format.json { render :show, status: :created, location: @word }
      else
        format.html { render :new }
        format.json { render json: @word.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /words/1
  # PATCH/PUT /words/1.json
  def update
    respond_to do |format|
      result = Words::Update.new(current_user, params[:id], word_params).call
      @word = result.word

      if result.success?
        format.html { redirect_to @word, notice: 'Word was successfully updated.' }
        format.json { render :show, status: :ok, location: @word }
      else
        format.html { render :edit }
        format.json { render json: @word.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /words/1
  # DELETE /words/1.json
  def destroy
    @word.destroy
    respond_to do |format|
      format.html { redirect_to words_url, notice: 'Word was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_word
      # Handle both numeric IDs and title-based slugs
      id_param = params[:id].to_s
      if id_param.match?(/^\d+$/)
        # Pure numeric ID - use ActiveRecord's original find
        @word = Word.where(id: params[:id]).first
        raise ActiveRecord::RecordNotFound unless @word
      else
        # Slug or title - use custom find method
        @word = Word.find(params[:id])
      end
    end

    def set_tags
      gon.all_tag_list = ActsAsTaggableOn::Tag.all.pluck(:name)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def word_params
      params.require(:word).permit(:title, :body, :tag_list)
    end
end
