module WordsHelper
  
  @@markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions = {})

  def markdown(str)
    @@markdown.render(str)
  end

  def add_word_link(body)
    word_list.each do |w|
      body.sub!(w, link_to(w, url_for(controller: :words, action: :show, id: w)))
    end
    body
  end

  private 
  def word_list
    Word.all.pluck(:title)
  end
end
