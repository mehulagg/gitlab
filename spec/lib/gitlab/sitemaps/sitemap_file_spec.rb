# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Sitemaps::SitemapFile do
  subject do
    described_class.new.tap do |file|
      file.add_elements("https://gitlab.com")
    end
  end

  describe '#render' do
    it 'generates a valid sitemap file' do
      content = subject.render
      expected_content = <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
        <url>
          <loc>https://gitlab.com</loc>
          <lastmod>2020-10-20</lastmod>
        </url>
      </urlset>
      EOS

      expect(content).to eq expected_content
    end
  end

  describe '#save' do
    it 'returns if no elements has been provided' do
      expect(File).not_to receive(:write)

      described_class.new.save
    end

    it 'stores the content in the public root folder' do
      expect(subject).to receive(:render).and_call_original

      expect(File).to receive(:write).with(
        File.join(Rails.public_path, 'sitemap.xml'),
        anything)

      subject.save
    end
  end
end
