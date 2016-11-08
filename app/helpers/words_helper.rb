module WordsHelper
  extensions = {strikethrough: true, fenced_code_blocks: true}
  @@markdown = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(
        hard_wrap: true,
      ),
    extensions)

  def markdown(str)
    @@markdown.render(str)
  end

  def add_word_link(body)
    word_list.each do |w|
      body = body.sub(w, link_to(w, url_for(controller: :words, action: :show, id: w)))
    end
    body
  end

  def has_version?(w)
    w.versions.count > 0
  end

  def recent_words
    Word.recent_words(Option.list_size_of_recent_words_parts)
  end

  private 
  def word_list
    Word.all.pluck(:title)
  end
end
