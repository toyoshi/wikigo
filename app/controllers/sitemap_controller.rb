class SitemapController < ActionController::Base
  
  def index
    # Set appropriate headers for XML sitemap
    response.headers['Content-Type'] = 'application/xml; charset=utf-8'
    
    # Get only words with content ordered by updated_at for efficient caching
    @words = Word.has_content.order(:updated_at)
    
    # Cache the sitemap for 1 hour
    expires_in 1.hour, public: true
    
    respond_to do |format|
      format.xml
    end
  end
  
  private
  
  # Helper method to generate full URL for a word
  def word_url(word)
    "#{request.protocol}#{request.host_with_port}/#{word.to_param}"
  end
  
  # Helper method to generate full URL for static pages
  def static_url(path)
    "#{request.protocol}#{request.host_with_port}#{path}"
  end
end