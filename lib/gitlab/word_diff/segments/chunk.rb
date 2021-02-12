# frozen_string_literal: true

module Gitlab
  module WordDiff
    module Segments
      class Chunk
        def initialize(line)
          @line = line
        end

        def old?
          line[0] == '-'
        end

        def new?
          line[0] == '+'
        end

        def to_s
          line[1..] || ''
        end

        def size
          to_s.size
        end

        private

        attr_reader :line
      end
    end
  end
end
