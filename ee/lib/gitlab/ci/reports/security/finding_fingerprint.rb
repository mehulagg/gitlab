# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        class FindingFingerprint
          attr_accessor :algorithm_type, :fingerprint_value

          def initialize(params = {})
            @algorithm_type = params.dig(:algorithm_type)
            @fingerprint_value = params.dig(:fingerprint_value)
          end

          def fingerprint_sha256
            Digest::SHA1.digest(fingerprint_value)
          end

          def to_h
            {
              algorithm_type: algorithm_type,
              fingerprint_sha256: fingerprint_sha256
            }
          end

          def valid?
            ::Vulnerabilities::FindingFingerprint.algorithm_types.key?(algorithm_type)
          end
        end
      end
    end
  end
end
