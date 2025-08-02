module WordsHelper
  def add_word_link(word)
    body = word.body
    except_word = word.title

    word_list(except_word).each do |w|
      body = body.to_s.gsub(w, link_to(w, url_for(controller: :words, action: :show, id: w.sub(' ', '-'))))
      #TODO: To DRY logic of space to dash (models/concerns/title_converter.rb)
    end
    body
  end
  
  def add_word_links_to_content(content, except_word = nil)
    return content if content.blank?
    
    html = content.to_s
    words = word_list(except_word)
    
    # Sort by length descending to match longer phrases first
    words.sort_by { |w| -w.length }.each do |word_title|
      # For Japanese text, we don't use word boundaries as they don't work well
      pattern = /#{Regexp.escape(word_title)}/
      
      if html.include?(word_title)
        link = link_to(word_title, word_path(word_title.gsub(' ', '-')), class: 'auto-link')
        # Replace all occurrences (gsub does global substitution)
        html = html.gsub(pattern, link)
      end
    end
    
    html.html_safe
  end

  def has_version?(w)
    w.versions.count > 0
  end

  def recent_words
    Word.recent_words(Option.list_size_of_recent_words_parts)
  end

  # For views/words/_form.html
  def template_list
    Word.tagged_with('Template').map do |w|
      [w.title, w.body]
    end
  end

  private 
  def word_list(except_word)
    Word.where.not(title: except_word).pluck(:title)
  end
end
