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

        def assign_type!(diff_line)
          return unless markers

          new_type =
            if markers.has_key?(diff_line.text)
              self.type = markers[diff_line.text]

              CONFLICT_MARKER
            else
              type
            end

          diff_line.type = new_type if new_type
        end

        private

        def build_markers(path, conflicts)
          return unless conflicts

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
