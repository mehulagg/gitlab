# frozen_string_literal: true

module Gitlab
  module Sitemap
    class Index
      MAX_SITEMAPS  = 50_000
      MAX_FILE_SIZE = 50_000_000

      MaxSitemapFiles = Class.new(StandardError)

      attr_accessor :sitemap_files
      attr_reader :sitemap_index_path

      def initialize(sitemap_index_path)
        @sitemap_files = []
        @sitemap_index_path = sitemap_index_path
      end

      def add_sitemap_file!(file)
        raise MaxSitemapFiles if sitemap_files.size == MAX_SITEMAPS

        sitemap_files << file
      end

      def generate
        File.write(sitemap_index_path, render)
      end

      private

      def render
        xml = Builder::XmlMarkup.new(:indent => 2)
        fragment = File.read(File.expand_path("../fragments/index.xml.builder", __FILE__))
        instance_eval fragment
      end
    end
  end
end
