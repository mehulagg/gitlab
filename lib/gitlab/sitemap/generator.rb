# frozen_string_literal: true

module Gitlab
  module Sitemap
    class Generator
      SITEMAPS_DIR = File.join(Rails.public_path, '-/sitemaps/')
      SITEMAP_INDEX_PATH = File.join(Rails.public_path, 'sitemap.xml')

      class << self
        def generate
          clean_sitemaps

          index = Sitemap::Index.new(SITEMAP_INDEX_PATH)

          FileGenerator.new(index).generate

          index.generate
        end

        private

        # Remove existing sitemaps dir and create it
        def clean_sitemaps
          FileUtils.remove_dir(SITEMAPS_DIR) if Dir.exist?(SITEMAPS_DIR)
          Dir.mkdir(SITEMAPS_DIR)
          FileUtils.remove_file(SITEMAP_INDEX_PATH) if File.exist?(SITEMAP_INDEX_PATH)
        end
      end
    end
  end
end
