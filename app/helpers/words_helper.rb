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
    placeholders = {}

    # Match longer titles first, and swap each match for a unique placeholder
    # before inserting the real links. This keeps a shorter title from
    # rewriting the markup of a link already produced by a longer one, which
    # would otherwise create nested <a> tags.
    titles_by_length_desc(except_word).each do |title|
      next unless html.include?(title)

      placeholder = "{{WORD_LINK_#{placeholders.size}}}"
      placeholders[placeholder] = link_to(title, word_link_path(title), class: 'auto-link')
      html = html.gsub(Regexp.escape(title), placeholder)
    end

    # Restore all placeholders to their real links once every title is matched.
    placeholders.each { |placeholder, link| html = html.gsub(placeholder, link) }

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

  # Linkable titles ordered longest-first so multi-word titles win over the
  # shorter titles they contain.
  def titles_by_length_desc(except_word)
    word_list(except_word).sort_by { |title| -title.length }
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
