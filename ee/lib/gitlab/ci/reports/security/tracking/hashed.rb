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
              Vulnerabilities::TrackingFingerprint.priority_hash_hash
            end

            def fingerprint_type
              Vulnerabilities::TrackingFingerprint.type_hash
            end

            def fingerprint_method
              Vulnerabilities::TrackingFingerprint.method_hash
            end

            def fingerprint_data
              @data.to_s
            end
          end
        end
      end
    end
  end
end
