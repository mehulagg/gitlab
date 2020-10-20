# frozen_string_literal: true

module Gitlab
  module Sitemaps
    class SitemapFile
      SITEMAP_INDEX_PATH = File.join(Rails.public_path, 'sitemap.xml')

      attr_accessor :urls

      def initialize
        @urls = []
      end

      def add_elements(elements = [])
        elements = Array(elements)

        return if elements.empty?

        urls << elements.map! { |element| Sitemaps::UrlExtractor.extract(element) }
      end

      def save
        return if urls.empty?

        File.write(SITEMAP_INDEX_PATH, render)
      end

      def render
        xml = Builder::XmlMarkup.new(:indent => 2)
        fragment = File.read(File.expand_path("../fragments/sitemap_file.xml.builder", __FILE__))
        instance_eval fragment
      end
    end
  end
end
