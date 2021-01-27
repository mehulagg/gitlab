# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        module Tracking
          module Source
            class Base < Tracking::Base
              attr_reader :track_data
              attr_reader :full_data

              def initialize(track_data, full_data)
                @track_data = track_data
                @full_data = full_data
              end

              def track_type
                ::Vulnerabilities::TrackingFingerprint.track_types[:source]
              end

              def location_hash
                # TODO support multiple locations in the frontend
                last_pos = full_data['positions'].last
                {
                  file: last_pos['file'],
                  start_line: last_pos['line_start'],
                  end_line: last_pos['line_end']
                }
              end
            end
          end
        end
      end
    end
  end
end
