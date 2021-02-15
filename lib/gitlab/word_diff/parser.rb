# frozen_string_literal: true

module Gitlab
  module WordDiff
    class Parser
      include Enumerable

      def initialize
        @chunks = ChunkCollection.new
        @counter = Counter.new
      end

      def parse(lines, diff_file: nil)
        return [] if lines.blank?

        Enumerator.new do |yielder|
          lines.each do |line|
            segment = LineProcessor.new(line).extract

            case segment
            when Segments::DiffHunk
              next if segment.first_line?

              counter.set_line_num(old: segment.old_line, new: segment.new_line)

              yielder << Gitlab::Diff::Line.new(segment.to_s, 'match', counter.line_obj_index, counter.line_old, counter.line_new, parent_file: diff_file)
              counter.increase_obj_index

            when Segments::Chunk
              @chunks.add(segment)

            when Segments::Newline
              yielder << Gitlab::Diff::Line.new(@chunks.content, 'word-diff', counter.line_obj_index, counter.line_old, counter.line_new, parent_file: diff_file, highlight_diffs: @chunks.highlight_diffs)

              @chunks.reset
              counter.increase_obj_index
              counter.increase_line_num
            end
          end
        end
      end

      private

      attr_reader :counter
    end
  end
end
