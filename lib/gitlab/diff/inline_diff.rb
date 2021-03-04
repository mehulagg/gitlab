# frozen_string_literal: true

module Gitlab
  module Diff
    class InlineDiff
      # Regex to find a run of deleted lines followed by the same number of added lines
      LINE_PAIRS_PATTERN = %r{
        # Runs start at the beginning of the string (the first line) or after a space (for an unchanged line)
        (?:\A|\s)

        # This matches a number of `-`s followed by the same number of `+`s through recursion
        (?<del_ins>
          -
          \g<del_ins>?
          \+
        )

        # Runs end at the end of the string (the last line) or before a space (for an unchanged line)
        (?=\s|\z)
      }x.freeze

      attr_accessor :old_line, :new_line, :offset

      def initialize(old_line, new_line, offset: 0)
        @old_line = old_line[offset..-1]
        @new_line = new_line[offset..-1]
        @offset = offset
      end

      def inline_diffs
        # Skip inline diff if empty line was replaced with content
        return if old_line == ""

        CharDiff.new(old_line, new_line).changed_ranges(offset: offset)
      end

      class << self
        def for_lines(lines)
          changed_line_pairs = find_changed_line_pairs(lines)

          inline_diffs = []

          changed_line_pairs.each do |old_index, new_index|
            old_line = lines[old_index]
            new_line = lines[new_index]

            old_diffs, new_diffs = new(old_line, new_line, offset: 1).inline_diffs

            inline_diffs[old_index] = old_diffs
            inline_diffs[new_index] = new_diffs
          end

          inline_diffs
        end

        private

        # Finds pairs of old/new line pairs that represent the same line that changed
        # rubocop: disable CodeReuse/ActiveRecord
        def find_changed_line_pairs(lines)
          # Prefixes of all diff lines, indicating their types
          # For example: `" - +  -+  ---+++ --+  -++"`
          line_prefixes = lines.each_with_object(+"") { |line, s| s << (line[0] || ' ') }.gsub(/[^ +-]/, ' ')

          changed_line_pairs = []
          line_prefixes.scan(LINE_PAIRS_PATTERN) do
            # For `"---+++"`, `begin_index == 0`, `end_index == 6`
            begin_index, end_index = Regexp.last_match.offset(:del_ins)

            # For `"---+++"`, `changed_line_count == 3`
            changed_line_count = (end_index - begin_index) / 2

            halfway_index = begin_index + changed_line_count
            (begin_index...halfway_index).each do |i|
              # For `"---+++"`, index 1 maps to 1 + 3 = 4
              changed_line_pairs << [i, i + changed_line_count]
            end
          end

          changed_line_pairs
        end
        # rubocop: enable CodeReuse/ActiveRecord
      end
    end
  end
end
