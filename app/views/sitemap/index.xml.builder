xml.instruct! :xml, version: '1.0'
xml.urlset xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  
  # Home page (highest priority)
  xml.url do
    xml.loc root_url
    xml.lastmod @words.maximum(:updated_at)&.iso8601
    xml.changefreq 'daily'
    xml.priority '1.0'
  end
  
  # Words index page
  xml.url do
    xml.loc words_index_url
    xml.lastmod @words.maximum(:updated_at)&.iso8601
    xml.changefreq 'daily'
    xml.priority '0.8'
  end
  
  # Tags index page
  xml.url do
    xml.loc tags_index_url
    xml.lastmod @words.maximum(:updated_at)&.iso8601
    xml.changefreq 'weekly'
    xml.priority '0.6'
  end
  
  # Individual word pages
  @words.find_each do |word|
    xml.url do
      xml.loc "#{request.protocol}#{request.host_with_port}/#{word.to_param}"
      xml.lastmod word.updated_at.iso8601
      xml.changefreq 'weekly'
      xml.priority '0.7'
    end
  end
  
  # Tag pages (if any tags exist)
  if Word.tag_counts_on(:tags).any?
    Word.tag_counts_on(:tags).find_each do |tag|
      xml.url do
        xml.loc word_tag_url(tag_list: tag.name)
        xml.lastmod @words.tagged_with(tag.name).maximum(:updated_at)&.iso8601
        xml.changefreq 'weekly'
        xml.priority '0.5'
      end
    end
  end
  
end