# frozen_string_literal: true

module Gitlab
  module Diff
    class InlineDiff
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
          pair_selector = Gitlab::Diff::PairSelector.new(lines)

          inline_diffs = []

          pair_selector.each do |old_diff_line, new_diff_line|
            old_diffs, new_diffs = new(old_diff_line.text, new_diff_line.text, offset: 1).inline_diffs

            inline_diffs[old_diff_line.index] = old_diffs
            inline_diffs[new_diff_line.index] = new_diffs
          end

          inline_diffs
        end
      end
    end
  end
end
