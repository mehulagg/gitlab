# frozen_string_literal: true

module Gitlab
  module WordDiff
    class LineProcessor
      def initialize(line)
        @line = line
      end

      def extract
        return if ignore?
        return Segments::DiffHunk.new(full_line) if diff_hunk?
        return Segments::Newline.new if newline_delimiter?

        Segments::Chunk.new(full_line)
      end

      def diff_hunk?
        line =~ /^@@ -/
      end

      def ignore?
        full_line == ' '
      end

      def newline_delimiter?
        full_line == '~'
      end

      private

      attr_reader :line

      def full_line
        @full_line ||= line.delete("\n")
      end
    end
  end
end
