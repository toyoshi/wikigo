module Words
  class Export
    def initialize
    end

    def call
      t = Tempfile.new('export-', temp_dir)

      Zip::OutputStream.open(t.path) do |z|
        Word.all.find_in_batches do |batch|
          batch.each do |w|
            z.put_next_entry("#{w.id}.html")
            z.print w.to_middleman
          end
        end
      end
      t.close
      t.path
    end

    private 

    def temp_dir
      path = Rails.root.join('tmp')
      Dir.mkdir(path) unless Dir.exist?(path)
      path
    end
  end
end
