# frozen_string_literal: true

module Gitlab
  module Sitemap
    class File
      def initialize
        @num_urls = 0
        @bytesize = 0
      end

      def add_url(url)
        #redered_text = Url.new(url).render
        @num_urls += 1
        @bytesize += 1
      end
    end
  end
end
