# frozen_string_literal: true

module BulkImports
  module Pipeline
    class ExtractedData
      attr_reader :data, :page_info

      def initialize(data: nil, page_info: {})
        @data = Array.wrap(data)
        @page_info = page_info
      end

      def has_next_page?
        page_info.dig('has_next_page')
      end

      def next_page
        page_info.dig('next_page')
      end

      def each(&block)
        data.each(&block)
      end
    end
  end
end
