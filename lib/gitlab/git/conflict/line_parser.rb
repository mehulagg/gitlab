# frozen_string_literal: true

module Gitlab
  module Git
    module Conflict
      class LineParser
        CONFLICT_OUR = 'conflict_our'
        CONFLICT_THEIR = 'conflict_their'
        CONFLICT_MARKER = 'conflict_marker'

        attr_reader :markers
        attr_accessor :type

        def initialize(path, conflicts)
          @markers = build_markers(path, conflicts)
          @type = nil
        end

        def diff_line_type(line)
          return unless markers

          if markers.has_key?(line)
            self.type = markers[line]

            return CONFLICT_MARKER
          end

          type
        end

        private

        def build_markers(path, conflicts)
          return unless path

          conflict = conflicts.files.find { |conflict| conflict.our_path == path }

          return unless conflict

          {
            "+<<<<<<< #{conflict.our_path}" => CONFLICT_OUR,
            "+=======" => CONFLICT_THEIR,
            "+>>>>>>> #{conflict.their_path}" => nil
          }
        end
      end
    end
  end
end
