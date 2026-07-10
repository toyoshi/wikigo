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
    placeholders = {}
    placeholder_id = 0
    
    # Sort by length descending to match longer phrases first
    words.sort_by { |w| -w.length }.each do |word_title|
      escaped_word = Regexp.escape(word_title)
      
      if html.include?(word_title)
        link = link_to(word_title, word_link_path(word_title), class: 'auto-link')
        
        # Create unique placeholder for this link
        placeholder_key = "{{WORD_LINK_#{placeholder_id}}}"
        placeholders[placeholder_key] = link
        placeholder_id += 1
        
        # Replace word with placeholder (safe from nested replacements)
        html = html.gsub(escaped_word, placeholder_key)
      end
    end
    
    # Restore all placeholders to actual links at the end
    placeholders.each do |placeholder, link|
      html = html.gsub(placeholder, link)
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

  # Generates the path for a word link. In a real request the view context
  # has a controller, so the regular named route helper is used (preserving
  # request context such as script_name). Outside a request (e.g. helper
  # tests), route helpers that rely on the controller raise NameError, so
  # fall back to the application's routes proxy instead.
  def word_link_path(title)
    id = title.gsub(' ', '-')
    if respond_to?(:controller) && controller
      word_path(id)
    else
      Rails.application.routes.url_helpers.word_path(id)
    end
  end
end
