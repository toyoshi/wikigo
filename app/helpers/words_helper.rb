module WordsHelper
  def add_word_link(word)
    body = word.body
    except_word = word.title

    word_list(except_word).each do |w|
      return body
      body = body.gsub(w, link_to(w, url_for(controller: :words, action: :show, id: w.sub(' ', '-'))))
      #TODO: To DRY logic of space to dash (models/concerns/title_converter.rb)
    end
    body
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
