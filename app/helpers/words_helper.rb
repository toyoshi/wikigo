class MyRedcarpet < Redcarpet::Render::HTML
  def header(text, header_level)
    %Q{<h#{header_level} id="#{text.downcase.gsub(" ", "-")}">#{text}</h#{header_level}>}.html_safe
  end
end

module WordsHelper
  extensions = {strikethrough: true, fenced_code_blocks: true}
  @@markdown = Redcarpet::Markdown.new(
      MyRedcarpet.new(
        hard_wrap: true,
        with_toc_data: true,
      ),
    extensions)
  @@toc = Redcarpet::Markdown.new Redcarpet::Render::HTML_TOC

  def markdown(str)
    @@markdown.render(str)
  end

  def toc(str)
    @@toc.render(str)
  end

  def add_word_link(body)
    word_list.each do |w|
      body.sub!(w, link_to(w, url_for(controller: :words, action: :show, id: w)))
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
