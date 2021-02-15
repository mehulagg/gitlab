# frozen_string_literal: true

module Gitlab
  module WordDiff
    class Counter
      def initialize
        @line_old = 1
        @line_new = 1
        @line_obj_index = 0
      end

      attr_reader :line_old, :line_new, :line_obj_index

      def increase_line_num
        @line_old += 1
        @line_new += 1
      end

      def increase_obj_index
        @line_obj_index += 1
      end

      def set_line_num(old:, new:)
        @line_old = old
        @line_new = new
      end
    end
  end
end
