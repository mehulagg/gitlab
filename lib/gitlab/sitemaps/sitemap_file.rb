module Gitlab
  module Sitemaps
    class SitemapFile
      SITEMAP_INDEX_PATH = File.join(Rails.public_path, 'sitemap.xml')

      attr_accessor :sitemap_urls

      def initialize
        @sitemap_urls = []
      end

      def add_urls(urls = [])
        urls = Array(urls)

        return if urls.empty?

        @sitemap_urls << urls
      end

      def add_groups(groups = [])
        groups = Array(groups)

        return if groups.empty?

        @sitemap_urls << groups.map { |group| Sitemaps::UrlExtractor.extract_from_group(group) }
      end

      def save
        return if sitemap_urls.empty?

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
