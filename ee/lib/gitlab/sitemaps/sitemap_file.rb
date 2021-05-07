# frozen_string_literal: true

module Gitlab
  module Sitemaps
    class SitemapFile
      SITEMAP_FILE_PATH = File.join(Rails.public_path, 'sitemap.xml').freeze

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
        return if empty?

        File.write(SITEMAP_FILE_PATH, render)
      end

      def render
        return if empty?

        fragment = File.read(File.expand_path("fragments/sitemap_file.xml.builder", __dir__))

        instance_eval fragment
      end

      def empty?
        urls.empty?
      end

      private

      def xml_builder
        @xml_builder ||= Builder::XmlMarkup.new(indent: 2)
      end

      def lastmod
        @lastmod ||= Date.today.iso8601
      end
    end
  end
end
