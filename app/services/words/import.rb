require 'zip'

module Words
  # Imports words from an uploaded zip archive of Middleman-style html files,
  # each with a leading YAML front matter block (title/tags) followed by the
  # body. Entries that are malformed or missing a title are counted as failures
  # rather than aborting the whole import. A malformed archive (or YAML) raises,
  # letting the caller surface an "Import failed" message.
  class Import
    Result = Struct.new(:imported_count, :failed_count)

    def initialize(archive)
      @archive = archive
    end

    def call
      imported_count = 0
      failed_count = 0

      Zip::File.open(@archive.tempfile) do |zip_file|
        zip_file.each do |entry|
          if import_entry(entry)
            imported_count += 1
          else
            failed_count += 1
          end
        end
      end

      Result.new(imported_count, failed_count)
    end

    private

    # Returns true when the entry was imported, false when it was skipped.
    def import_entry(entry)
      content = entry.get_input_stream.read.force_encoding('utf-8')

      # Split by --- and handle the format properly
      parts = content.split('---', 3)

      # Skip if not enough parts
      return false if parts.length < 3

      # The YAML header is the second part (first is empty)
      file_header = parts[1]
      file_body = parts[2]

      header = YAML.safe_load(file_header, permitted_classes: [Date, Time, DateTime])

      # Use string keys instead of symbols
      title = header['title'] || header[:title]
      tags = header['tags'] || header[:tags]

      return false unless title

      word = Word.find_or_create_by(title: title)
      word.tag_list = tags if tags
      word.body = file_body.strip if file_body
      word.save
    end
  end
end
