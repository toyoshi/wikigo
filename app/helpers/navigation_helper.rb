module NavigationHelper
  def parse_sidebar_navigation(content)
    return [] if content.blank?
    
    # ActionTextコンテンツをHTMLに変換
    html = content.to_s
    doc = Nokogiri::HTML::DocumentFragment.parse(html)
    
    navigation_items = []
    current_section = nil
    
    doc.children.each do |node|
      case node.name
      when /^h[1-6]$/i  # 見出しタグ (h1-h6)
        # 新しいセクションを開始
        current_section = {
          title: node.text.strip,
          level: node.name[1].to_i,
          items: []
        }
        navigation_items << current_section
        
      when 'ul', 'ol'  # リストタグ
        if current_section
          # リスト内のリンクを抽出
          node.css('li').each do |li|
            link = li.css('a').first
            if link
              current_section[:items] << {
                text: link.text.strip,
                url: link['href'],
                active: current_page?(link['href'])
              }
            else
              # リンクがない場合はテキストのみ
              text = li.text.strip
              unless text.blank?
                current_section[:items] << {
                  text: text,
                  url: nil,
                  active: false
                }
              end
            end
          end
        end
      end
    end
    
    navigation_items
  end
  
  def render_navigation_section(section)
    content_tag :div, class: 'nav-section' do
      header = content_tag :div, section[:title], class: 'nav-section-header'
      
      items = if section[:items].any?
        content_tag :ul, class: 'nav-section-items' do
          section[:items].map do |item|
            li_class = 'nav-item'
            li_class += ' active' if item[:active]
            
            content_tag :li, class: li_class do
              if item[:url]
                link_to item[:text], item[:url], class: 'nav-link'
              else
                content_tag :span, item[:text], class: 'nav-text'
              end
            end
          end.join.html_safe
        end
      else
        ''
      end
      
      header + items
    end
  end
end