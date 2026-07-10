module NavigationHelper
  # Parses ActionText/HTML into a list of navigation sections. Each heading
  # (h1-h6) starts a new section; the list items (ul/ol) that follow it become
  # that section's links.
  def parse_sidebar_navigation(content)
    return [] if content.blank?

    doc = Nokogiri::HTML::DocumentFragment.parse(content.to_s)

    sections = []
    current_section = nil

    doc.children.each do |node|
      case node.name
      when /^h[1-6]$/i
        current_section = new_section(node)
        sections << current_section
      when 'ul', 'ol'
        next unless current_section

        node.css('li').each do |li|
          item = navigation_item(li)
          current_section[:items] << item if item
        end
      end
    end

    sections
  end

  def render_navigation_section(section)
    content_tag :div, class: 'nav-section' do
      header = content_tag :div, section[:title], class: 'nav-section-header'
      header + render_navigation_items(section[:items])
    end
  end

  private

  def new_section(heading_node)
    {
      title: heading_node.text.strip,
      level: heading_node.name[1].to_i,
      items: []
    }
  end

  # Builds a single navigation item from a <li>. Returns nil for empty,
  # link-less items so they are skipped.
  def navigation_item(li)
    link = li.css('a').first
    if link
      { text: link.text.strip, url: link['href'], active: current_page?(link['href']) }
    else
      text = li.text.strip
      { text: text, url: nil, active: false } unless text.blank?
    end
  end

  def render_navigation_items(items)
    return '' if items.empty?

    content_tag :ul, class: 'nav-section-items' do
      safe_join(items.map { |item| render_navigation_item(item) })
    end
  end

  def render_navigation_item(item)
    li_class = item[:active] ? 'nav-item active' : 'nav-item'

    content_tag :li, class: li_class do
      if item[:url]
        link_to item[:text], item[:url], class: 'nav-link'
      else
        content_tag :span, item[:text], class: 'nav-text'
      end
    end
  end
end
