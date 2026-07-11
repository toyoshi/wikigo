class Api::V1::WordsController < Api::V1::BaseController
  before_action :set_word, only: [:show, :update, :destroy]
  before_action :set_search, only: [:index]

  # GET /api/v1/words
  def index
    @words = paginate(sorted_by_params(@search.result))

    render json: {
      words: serialize_words(@words),
      pagination: pagination_meta(@words)
    }
  end

  # GET /api/v1/words/:id
  def show
    render_word(@word)
  end

  # POST /api/v1/words
  def create
    result = Words::Create.new(current_user, word_params).call

    if result.success?
      render_word(result.word, status: :created)
    else
      render_validation_failed('Could not create word', result.word.errors.full_messages)
    end
  end

  # PATCH/PUT /api/v1/words/:id
  def update
    result = Words::Update.new(current_user, @word.to_param, word_params).call

    if result.success?
      render_word(result.word)
    else
      render_validation_failed('Could not update word', result.word.errors.full_messages)
    end
  end

  # DELETE /api/v1/words/:id
  def destroy
    if @word.destroy
      render json: { message: 'Word deleted successfully' }
    else
      render_validation_failed('Could not delete word', @word.errors.full_messages)
    end
  end

  # GET /api/v1/words/search
  def search
    return render_bad_request('Search query (q) parameter is required') if params[:q].blank?

    @words = paginate(Word.ransack(title_or_body_contains: params[:q]).result.order(updated_at: :desc))

    render json: {
      query: params[:q],
      words: serialize_words(@words),
      pagination: pagination_meta(@words)
    }
  end

  # GET /api/v1/words/tags
  def tags
    @tags = Word.tag_counts_on(:tags)

    render json: {
      tags: @tags.map { |tag| { name: tag.name, count: tag.taggings_count } }
    }
  end

  # GET /api/v1/words/tagged/:tag
  def tagged
    @words = paginate(Word.tagged_with(params[:tag]).order(updated_at: :desc))

    render json: {
      tag: params[:tag],
      words: serialize_words(@words),
      pagination: pagination_meta(@words)
    }
  end

  private

  def set_word
    # Use ActiveRecord's original find for API (supports both ID and slug)
    if params[:id].match?(/^\d+$/)
      # Pure numeric ID
      @word = Word.find_by(id: params[:id])
    else
      # Slug or title
      @word = Word.find_by(title: Word.param_to_title(params[:id]))
    end

    raise ActiveRecord::RecordNotFound unless @word
  end

  def set_search
    @search = Word.ransack(params[:q])
  end

  def word_params
    params.require(:word).permit(:title, :body, :tag_list)
  end

  # Sorting for the index action. Unknown/blank sort values fall back to
  # most-recently-updated first.
  def sorted_by_params(scope)
    case params[:sort]
    when 'created_at_asc'  then scope.order(created_at: :asc)
    when 'created_at_desc' then scope.order(created_at: :desc)
    when 'updated_at_asc'  then scope.order(updated_at: :asc)
    when 'updated_at_desc' then scope.order(updated_at: :desc)
    when 'title_asc'       then scope.order(title: :asc)
    when 'title_desc'      then scope.order(title: :desc)
    else scope.order(updated_at: :desc)
    end
  end

  # Apply Kaminari pagination from page/per_page params (per_page capped at 100).
  def paginate(scope)
    page = params[:page]&.to_i || 1
    per_page = [params[:per_page]&.to_i || 25, 100].min

    scope.page(page).per(per_page)
  end

  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count,
      per_page: collection.limit_value
    }
  end

  def serialize_words(words)
    words.map { |word| word_json(word) }
  end

  def render_word(word, status: :ok)
    render json: { word: word_json(word, include_body: true) }, status: status
  end

  def word_json(word, include_body: false)
    result = {
      id: word.id,
      title: word.title,
      slug: word.to_param,
      tags: word.tag_list,
      created_at: word.created_at.iso8601,
      updated_at: word.updated_at.iso8601,
      url: "/#{word.to_param}"
    }

    if include_body
      result[:body] = word.body.to_s
      begin
        result[:body_html] = word.body.present? ? word.body.to_html : ''
      rescue NoMethodError
        # Fallback if to_html is not available
        result[:body_html] = word.body.to_s
      end
    end

    result
  end
end
