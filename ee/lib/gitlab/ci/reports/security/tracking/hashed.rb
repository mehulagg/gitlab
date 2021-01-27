# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        module Tracking
          class Hashed < Base
            attr_reader :data

            def initialize(data:)
              @data = data
            end

            private

            def self.priority
              ::Vulnerabilities::TrackingFingerprint.priorities[:hash_hash]
            end

            def track_type
              ::Vulnerabilities::TrackingFingerprint.track_types[:hash]
            end

            def track_method
              ::Vulnerabilities::TrackingFingerprint.track_methods[:hash]
            end

            def track_data
              @data.to_s
            end
          end
        end
      end
    end
  end
end
