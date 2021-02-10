# frozen_string_literal: true

module Gitlab
  module Diff
    class HighlightedLines
      attr_reader :diff_file, :diff_lines, :new_chunks, :old_chunks, :mapper

      def initialize(diff_file)
        @diff_file = diff_file
        @diff_lines = diff_file.diff_lines
        @new_chunks = []
        @old_chunks = []
        @mapper = {}

        calculate!
      end

      def for(diff_line, index)
        return if mapper.blank?

        chunk_type, chunk_index, line_index = mapper[index]

        lines =
          if chunk_type == :new
            new_chunks[chunk_index]
          elsif chunk_type == :old
            old_chunks[chunk_index]
          end

        return unless lines

        # Add prefix to make the output similar to the current Gitlab::Diff::Highlight logic
        # When/If the logic from this class is established and blobless_diff_highlighting FF is removed
        # We can remove these lines and fix the tests
        rich_line = lines[line_index]
        if rich_line
          line_prefix = diff_line.text =~ /\A(.)/ ? Regexp.last_match(1) : ' '
          "#{line_prefix}#{rich_line}".html_safe
        end
      end

      private

      def calculate!
        return unless diff_file && diff_file.diff_refs

        new_lines, old_lines = [], []

        diff_lines.each_with_index do |diff_line, index|
          # Remove line prefix (+ or -) from the beginning of the line
          text = diff_line.text[1..-1].to_s

          if diff_line.unchanged? || diff_line.added?
            mapper[index] = [:new, new_chunks.size, new_lines.size]

            new_lines << text
          end

          if diff_line.removed?
            mapper[index] = [:old, old_chunks.size, old_lines.size]

            old_lines << text
          end

          if diff_line.meta?
            new_chunks << highlighted(diff_file.new_path, new_lines)
            old_chunks << highlighted(diff_file.old_path, old_lines)

            new_lines, old_lines = [], []
          end
        end

        new_chunks << highlighted(diff_file.new_path, new_lines)
        old_chunks << highlighted(diff_file.old_path, old_lines)
      end

      def highlighted(path, lines)
        Gitlab::Highlight.highlight(path, lines.join("\n")).lines
      end
    end
  end
end
