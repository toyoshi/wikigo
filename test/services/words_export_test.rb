require 'test_helper'
require 'zip'

class WordsExportTest < ActiveSupport::TestCase
  test "writes every word to a zip file, one HTML entry per word" do
    zip_path = Words::Export.new.call

    begin
      assert File.exist?(zip_path)

      entries = {}
      Zip::File.open(zip_path) do |zip|
        zip.each { |entry| entries[entry.name] = entry.get_input_stream.read }
      end

      Word.find_each do |word|
        entry_name = "#{word.id}.html"
        assert entries.key?(entry_name), "expected zip to contain #{entry_name}"
        assert_equal word.to_middleman, entries[entry_name]
      end

      assert_equal Word.count, entries.size
    ensure
      File.delete(zip_path) if zip_path && File.exist?(zip_path)
    end
  end

  test "the exported entry content matches the word's middleman front matter" do
    word = Word.first
    zip_path = Words::Export.new.call

    begin
      content = Zip::File.open(zip_path) { |zip| zip.read("#{word.id}.html") }

      assert_includes content, "title: #{word.title}"
      assert_includes content, "wiki:word_id: #{word.id}"
    ensure
      File.delete(zip_path) if zip_path && File.exist?(zip_path)
    end
  end
end
