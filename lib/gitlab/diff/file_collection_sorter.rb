# frozen_string_literal: true

module Gitlab
  module Diff
    class FileCollectionSorter
      attr_reader :diffs

      def initialize(diffs)
        @diffs = diffs
      end

      def sort
        diffs.sort do |a, b|
          a_bits = (a.new_path.presence || a.old_path).split(::File::SEPARATOR)
          b_bits = (b.new_path.presence || b.old_path).split(::File::SEPARATOR)

          sort_bits(a_bits, b_bits)
        end
      end

      private

      def sort_bits(a_bits, b_bits)
        a_bit = a_bits.shift
        b_bit = b_bits.shift
        comparison = a_bit <=> b_bit

        if a_bits.size < b_bits.size
          return 1 if a_bits.empty?
        elsif a_bits.size > b_bits.size
          return -1 if b_bits.empty?
        end

        return sort_bits(a_bits, b_bits) if comparison == 0

        comparison
      end
    end
  end
end
