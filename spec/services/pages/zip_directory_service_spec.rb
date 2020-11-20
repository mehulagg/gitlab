# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Pages::ZipDirectoryService do
  def create_pages_directory(dir)
    pages_dir = File.join(dir, "/public")

    Dir.mkdir pages_dir

    File.open(File.join(pages_dir, "index.html"), "w") do |f|
      f.write("some html")
    end
  end

  it 'zip pages directory' do
    archive = Tempfile.new("archive.zip")

    Dir.mktmpdir do |dir|
      create_pages_directory(dir)

      described_class.new(dir, archive).execute

      Zip::File.open(archive) do |zip_file|
        expect(zip_file.entries.count).to eq(2)
        expect(zip_file.glob('public').first.name).to eq("public/")
        expect(zip_file.glob('public/index.html').first.name).to eq("public/index.html")
      end
    end
  end
end
