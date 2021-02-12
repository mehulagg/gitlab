# frozen_string_literal: true

module Gitlab
  module WordDiff
    class Parser
      include Enumerable

      def initialize
        @line_obj_index = 0
        @line_old = 1
        @line_new = 1
        @chunks = ChunkCollection.new
      end

      def parse(lines, diff_file: nil)
        return [] if lines.blank?

        Enumerator.new do |yielder|
          lines.each do |line|
            segment = LineProcessor.new(line).extract

            case segment
            when Segments::DiffHunk
              set_line(old: segment.old_line, new: segment.new_line)

              next if top_of_file?

              yielder << Gitlab::Diff::Line.new(segment.to_s, 'match', line_obj_index, line_old, line_new, parent_file: diff_file)
              @line_obj_index += 1

            when Segments::Chunk
              @chunks.add(segment)

            when Segments::Newline
              yielder << Gitlab::Diff::Line.new(@chunks.content, 'word-diff', line_obj_index, line_old, line_new, parent_file: diff_file, highlight_diffs: @chunks.highlight_diffs)

              @chunks.reset
              @line_obj_index += 1
              @line_new += 1
              @line_old += 1
            end
          end
        end
      end

      private

      attr_reader :line_obj_index, :line_old, :line_new

      def set_line(old:, new:)
        @line_old = old
        @line_new = new
      end

      def top_of_file?
        line_old <= 1 && line_new <= 1
      end
    end
  end
end
