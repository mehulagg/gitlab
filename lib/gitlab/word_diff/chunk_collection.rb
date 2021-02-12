# frozen_string_literal: true

module Gitlab
  module WordDiff
    class ChunkCollection
      def initialize
        @chunks = []
      end

      def add(chunk)
        @chunks << chunk
      end

      def content
        @chunks.join('')
      end

      def highlight_diffs
        tmp = ''

        @chunks.each_with_object([[], []]) do |element, diff|
          diff[0] << (tmp.size...tmp.size + element.size) if element.old?
          diff[1] << (tmp.size...tmp.size + element.size) if element.new?
          tmp += element.to_s
        end
      end

      def reset
        @chunks = []
      end
    end
  end
end
