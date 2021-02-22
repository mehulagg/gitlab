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

          def valid?
            ::Vulnerabilities::FindingFingerprint.algorithm_types.key?(algorithm_type)
          end

          def priority
            ::Vulnerabilities::FindingFingerprint.priority(algorithm_type)
          end

          def fingerprint_sha256
            Digest::SHA1.digest(fingerprint_value)
          end

          def fingerprint_hex
            fingerprint_sha256.unpack("H*")[0]
          end

          def to_hash
            {
              algorithm_type: algorithm_type,
              fingerprint_sha256: fingerprint_sha256
            }
          end

          def eql?(other)
            other.algorithm_type == algorithm_type &&
              other.fingerprint_sha256 == fingerprint_sha256
          end

          alias_method :==, :eql?
        end
      end
    end
  end
end
