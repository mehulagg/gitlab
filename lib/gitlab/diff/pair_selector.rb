# frozen_string_literal: true

module Gitlab
  module Diff
    class PairSelector
      include Enumerable

      def initialize(diff_lines)
        @diff_lines = diff_lines
      end

      # Finds pairs of old/new line pairs that represent the same line that changed
      # rubocop: disable CodeReuse/ActiveRecord
      def each
        matches = {}

        diff_lines.each do |diff_line|
          if diff_line.removed?
            matches[diff_line.old_pos] = diff_line
          end

          if diff_line.added? && matches[diff_line.new_pos]
            yield [matches[diff_line.new_pos], diff_line]
          end
        end
      end
      # rubocop: enable CodeReuse/ActiveRecord

      private

      attr_reader :diff_lines
    end
  end
end
