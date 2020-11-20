# frozen_string_literal: true

module Pages
  class ZipDirectoryService
    PUBLIC_DIR = 'public'

    def initialize(input_dir, output_file)
      @input_dir = input_dir
      @output_file = output_file
    end

    def execute
      ::Zip::File.open(@output_file, ::Zip::File::CREATE) do |zipfile|
        write_entries zipfile, [PUBLIC_DIR], ''
      end
    end

    private

    # A helper method to make the recursion work.
    def write_entries(zipfile, entries, path)
      entries.each do |e|
        zipfile_path = path == '' ? e : File.join(path, e)
        disk_file_path = File.join(@input_dir, zipfile_path)

        if File.directory? disk_file_path
          recursively_deflate_directory(zipfile, disk_file_path, zipfile_path)
        else
          put_into_archive(zipfile, disk_file_path, zipfile_path)
        end
      end
    end

    def recursively_deflate_directory(zipfile, disk_file_path, zipfile_path)
      zipfile.mkdir zipfile_path
      subdir = Dir.entries(disk_file_path) - %w[. ..]
      write_entries zipfile, subdir, zipfile_path
    end

    def put_into_archive(zipfile, disk_file_path, zipfile_path)
      zipfile.add(zipfile_path, disk_file_path)
    end
  end
end
