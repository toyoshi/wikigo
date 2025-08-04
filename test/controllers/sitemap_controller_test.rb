require 'test_helper'

class SitemapControllerTest < ActionDispatch::IntegrationTest
  
  test "should get sitemap xml" do
    get '/sitemap.xml'
    assert_response :success
    assert_equal 'application/xml; charset=utf-8', response.content_type
  end
  
  test "sitemap should contain urlset element" do
    get '/sitemap.xml'
    assert_response :success
    
    # Parse XML response
    doc = Nokogiri::XML(response.body)
    assert_not_nil doc.at_xpath('//xmlns:urlset', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9')
  end
  
  test "sitemap should contain home page with highest priority" do
    get '/sitemap.xml'
    assert_response :success
    
    doc = Nokogiri::XML(response.body)
    home_url = doc.at_xpath('//xmlns:url[xmlns:priority="1.0"]/xmlns:loc', 
                           'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9')
    assert_not_nil home_url
    assert_includes home_url.text, 'http://www.example.com'
  end
  
  test "sitemap should contain all words" do
    # Create test words
    word1 = Word.create!(title: "Test Word 1", body: "Content 1")
    word2 = Word.create!(title: "Test Word 2", body: "Content 2")
    
    get '/sitemap.xml'
    assert_response :success
    
    doc = Nokogiri::XML(response.body)
    
    # Check if words are included
    urls = doc.xpath('//xmlns:url/xmlns:loc', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9')
    url_texts = urls.map(&:text)
    
    assert url_texts.any? { |url| url.include?(word1.to_param) }
    assert url_texts.any? { |url| url.include?(word2.to_param) }
  end
  
  test "sitemap should have proper XML structure" do
    get '/sitemap.xml'
    assert_response :success
    
    doc = Nokogiri::XML(response.body)
    
    # Check required elements exist
    assert doc.at_xpath('//xmlns:urlset', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9')
    assert doc.xpath('//xmlns:url', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9').any?
    assert doc.xpath('//xmlns:loc', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9').any?
    assert doc.xpath('//xmlns:lastmod', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9').any?
    assert doc.xpath('//xmlns:priority', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9').any?
  end
  
  test "sitemap should include static pages" do
    get '/sitemap.xml'
    assert_response :success
    
    doc = Nokogiri::XML(response.body)
    urls = doc.xpath('//xmlns:url/xmlns:loc', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9')
    url_texts = urls.map(&:text)
    
    # Check for static pages
    assert url_texts.any? { |url| url.include?('/-/index') } # words index
    assert url_texts.any? { |url| url.include?('/tags') } # tags index
  end
  
  test "sitemap should set cache headers" do
    get '/sitemap.xml'
    assert_response :success
    
    # Check cache control headers
    assert_not_nil response.headers['Cache-Control']
    assert_includes response.headers['Cache-Control'], 'max-age=3600' # 1 hour
  end
  
end