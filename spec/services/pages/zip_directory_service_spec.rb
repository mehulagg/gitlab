# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Pages::ZipDirectoryService do
  let(:dirs) do
    [
      "public",
      "public/nested"
    ]
  end

  let(:files) do
    [
      ["public/index.html", "index"],
      ["public/nested/nested.html", "nested"]
    ]
  end

  let(:links) do
    [
      []
    ]
  end

  def create_pages_directory(work_dir)
    dirs.each do |dir|
      Dir.mkdir File.join(work_dir, dir)
    end

    files.each do |file_name, file_content|
      File.open(File.join(work_dir, file_name), "w") do |f|
        f.write(file_content)
      end
    end
  end

  it 'zip pages directory' do
    archive = Tempfile.new("archive.zip")

    Dir.mktmpdir do |dir|
      create_pages_directory(dir)

      described_class.new(dir, archive).execute

      Zip::File.open(archive) do |zip_file|
        expect(zip_file.entries.count).to eq(dirs.count + files.count)

        dirs.each do |dir|
          entry = zip_file.glob(dir).first
          expect(entry.name).to eq(dir + "/")
          expect(entry.ftype).to eq(:directory)
        end

        files.each do |file_name, file_content|
          entry = zip_file.glob(file_name).first
        end
        expect(zip_file.glob('public/index.html').first.name).to eq("public/index.html")
        binding.pry
      end
    end
  end
end
