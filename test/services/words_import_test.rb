require 'test_helper'
require 'zip'
require 'ostruct'

class WordsImportTest < ActiveSupport::TestCase
  # Mimics the uploaded-file object the controller hands to the service: it only
  # needs to respond to #tempfile with something Zip::File can open.
  def archive_for(zip_path)
    OpenStruct.new(tempfile: File.new(zip_path))
  end

  def build_zip(entries)
    zip_file = Tempfile.new(['import', '.zip'])
    Zip::OutputStream.open(zip_file.path) do |z|
      entries.each do |name, content|
        z.put_next_entry(name)
        z.print content
      end
    end
    zip_file
  end

  test "imports words with front matter and reports counts" do
    Word.where(title: 'Imported Page').destroy_all

    zip_file = build_zip(
      'imported.html' => <<~EOS
        ---
        title: Imported Page
        tags: alpha, beta
        ---

        <p>Body content here</p>
      EOS
    )

    begin
      result = Words::Import.new(archive_for(zip_file.path)).call

      assert_equal 1, result.imported_count
      assert_equal 0, result.failed_count

      word = Word.find_by(title: 'Imported Page')
      assert_not_nil word
      assert_equal %w[alpha beta], word.tag_list.sort
      assert_match 'Body content here', word.body.to_s
    ensure
      zip_file.close
      zip_file.unlink
    end
  end

  test "counts entries without a title or front matter as failures" do
    zip_file = build_zip(
      'no_frontmatter.html' => "just some text, no yaml header",
      'no_title.html' => "---\ntags: x\n---\n\nbody"
    )

    begin
      result = Words::Import.new(archive_for(zip_file.path)).call

      assert_equal 0, result.imported_count
      assert_equal 2, result.failed_count
    ensure
      zip_file.close
      zip_file.unlink
    end
  end
end
