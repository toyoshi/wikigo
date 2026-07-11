require 'test_helper'

class NavigationHelperTest < ActionView::TestCase
  include NavigationHelper

  # current_page? needs a request context that unit tests lack; stub it so the
  # parsing logic can be exercised in isolation.
  def current_page?(_url)
    false
  end

  test "returns empty array for blank content" do
    assert_equal [], parse_sidebar_navigation("")
    assert_equal [], parse_sidebar_navigation(nil)
  end

  test "builds a section per heading with its list links" do
    html = <<~HTML
      <h2>Docs</h2>
      <ul>
        <li><a href="/getting-started">Getting Started</a></li>
        <li>Just text</li>
      </ul>
    HTML

    sections = parse_sidebar_navigation(html)

    assert_equal 1, sections.size
    section = sections.first
    assert_equal "Docs", section[:title]
    assert_equal 2, section[:level]
    assert_equal 2, section[:items].size

    link_item, text_item = section[:items]
    assert_equal({ text: "Getting Started", url: "/getting-started", active: false }, link_item)
    assert_equal({ text: "Just text", url: nil, active: false }, text_item)
  end

  test "ignores list items before any heading" do
    html = "<ul><li><a href='/x'>X</a></li></ul>"
    assert_equal [], parse_sidebar_navigation(html)
  end

  test "renders a section with links and text items" do
    section = {
      title: "Docs",
      level: 2,
      items: [
        { text: "Home", url: "/home", active: true },
        { text: "Plain", url: nil, active: false }
      ]
    }

    html = render_navigation_section(section)

    assert_includes html, 'class="nav-section"'
    assert_includes html, 'nav-section-header">Docs'
    assert_includes html, 'class="nav-item active"'
    assert_includes html, '<a class="nav-link" href="/home">Home</a>'
    assert_includes html, '<span class="nav-text">Plain</span>'
  end

  test "renders no list when a section has no items" do
    html = render_navigation_section(title: "Empty", level: 1, items: [])
    assert_includes html, 'class="nav-section"'
    refute_includes html, 'nav-section-items'
  end
end
