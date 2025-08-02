class Api::V1::WordsController < Api::V1::BaseController
  before_action :set_word, only: [:show, :update, :destroy]
  before_action :set_search, only: [:index]
  
  # GET /api/v1/words
  def index
    @words = @search.result
    
    # Apply sorting
    if params[:sort].present?
      case params[:sort]
      when 'created_at_asc'
        @words = @words.order(created_at: :asc)
      when 'created_at_desc'
        @words = @words.order(created_at: :desc)
      when 'updated_at_asc'
        @words = @words.order(updated_at: :asc)
      when 'updated_at_desc'
        @words = @words.order(updated_at: :desc)
      when 'title_asc'
        @words = @words.order(title: :asc)
      when 'title_desc'
        @words = @words.order(title: :desc)
      else
        @words = @words.order(updated_at: :desc)
      end
    else
      @words = @words.order(updated_at: :desc)
    end
    
    # Apply pagination
    page = params[:page]&.to_i || 1
    per_page = [params[:per_page]&.to_i || 25, 100].min # Max 100 items per page
    
    @words = @words.page(page).per(per_page)
    
    render json: {
      words: @words.map { |word| word_json(word) },
      pagination: {
        current_page: @words.current_page,
        total_pages: @words.total_pages,
        total_count: @words.total_count,
        per_page: @words.limit_value
      }
    }
  end
  
  # GET /api/v1/words/:id
  def show
    render json: {
      word: word_json(@word, include_body: true)
    }
  end
  
  # POST /api/v1/words
  def create
    result = Words::Create.new(current_user, word_params).call
    
    if result.success?
      render json: {
        word: word_json(result.word, include_body: true)
      }, status: :created
    else
      render json: {
        error: 'Validation Failed',
        message: 'Could not create word',
        details: result.word.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
  
  # PATCH/PUT /api/v1/words/:id
  def update
    result = Words::Update.new(current_user, @word.to_param, word_params).call
    
    if result.success?
      render json: {
        word: word_json(result.word, include_body: true)
      }
    else
      render json: {
        error: 'Validation Failed',
        message: 'Could not update word',
        details: result.word.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
  
  # DELETE /api/v1/words/:id
  def destroy
    @word.destroy
    
    render json: {
      message: 'Word deleted successfully'
    }
  end
  
  # GET /api/v1/words/search
  def search
    if params[:q].blank?
      render json: {
        error: 'Bad Request',
        message: 'Search query (q) parameter is required'
      }, status: :bad_request
      return
    end
    
    @words = Word.ransack(
      title_or_body_cont: params[:q]
    ).result
    
    # Apply sorting
    @words = @words.order(updated_at: :desc)
    
    # Apply pagination
    page = params[:page]&.to_i || 1
    per_page = [params[:per_page]&.to_i || 25, 100].min
    
    @words = @words.page(page).per(per_page)
    
    render json: {
      query: params[:q],
      words: @words.map { |word| word_json(word) },
      pagination: {
        current_page: @words.current_page,
        total_pages: @words.total_pages,
        total_count: @words.total_count,
        per_page: @words.limit_value
      }
    }
  end
  
  # GET /api/v1/words/tags
  def tags
    @tags = Word.tag_counts_on(:tags)
    
    render json: {
      tags: @tags.map { |tag| 
        {
          name: tag.name,
          count: tag.taggings_count
        }
      }
    }
  end
  
  # GET /api/v1/words/tagged/:tag
  def tagged
    tag_name = params[:tag]
    @words = Word.tagged_with(tag_name)
    
    # Apply sorting
    @words = @words.order(updated_at: :desc)
    
    # Apply pagination
    page = params[:page]&.to_i || 1
    per_page = [params[:per_page]&.to_i || 25, 100].min
    
    @words = @words.page(page).per(per_page)
    
    render json: {
      tag: tag_name,
      words: @words.map { |word| word_json(word) },
      pagination: {
        current_page: @words.current_page,
        total_pages: @words.total_pages,
        total_count: @words.total_count,
        per_page: @words.limit_value
      }
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