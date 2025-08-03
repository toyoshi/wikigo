#!/usr/bin/env ruby

# Debug script to test placeholder-based word linking logic
def debug_word_links
  # Simulate word list (longest first)
  words = ["馬超と張飛", "張飛卒", "張飛"]
  content = "張飛卒は勇敢だった。張飛も強かった。"
  
  puts "=== Placeholder-based Word Linking Test ==="
  puts "Original content: #{content}"
  puts "Words (sorted by length): #{words.sort_by { |w| -w.length }}"
  puts ""
  
  html = content.dup
  placeholders = {}
  placeholder_id = 0
  
  words.sort_by { |w| -w.length }.each_with_index do |word_title, index|
    puts "#{index + 1}. Processing: '#{word_title}' (#{word_title.length} chars)"
    
    if html.include?(word_title)
      puts "   Found '#{word_title}' in: #{html}"
      
      # Create link and placeholder
      link = "<a href='/#{word_title}'>#{word_title}</a>"
      placeholder_key = "{{WORD_LINK_#{placeholder_id}}}"
      placeholders[placeholder_key] = link
      placeholder_id += 1
      
      puts "   Creating placeholder: #{placeholder_key} → #{link}"
      
      # Replace with placeholder
      html = html.gsub(word_title, placeholder_key)
      puts "   After placeholder replacement: #{html}"
    else
      puts "   '#{word_title}' not found in current html"
    end
    puts ""
  end
  
  puts "=== Restoring Placeholders ==="
  puts "Before restoration: #{html}"
  puts "Placeholders: #{placeholders}"
  
  # Restore placeholders
  placeholders.each do |placeholder, link|
    puts "Restoring #{placeholder} → #{link}"
    html = html.gsub(placeholder, link)
  end
  
  puts ""
  puts "Final result: #{html}"
end

debug_word_links