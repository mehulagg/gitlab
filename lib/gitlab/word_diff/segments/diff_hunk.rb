# frozen_string_literal: true

module Gitlab
  module WordDiff
    module Segments
      class DiffHunk
        def initialize(line)
          @line = line
        end

        def old_line
          line.match(/\-[0-9]*/)[0].to_i.abs rescue 0
        end

        def new_line
          line.match(/\+[0-9]*/)[0].to_i.abs rescue 0
        end

        def to_s
          line
        end

        private

        attr_reader :line
      end
    end
  end
end
