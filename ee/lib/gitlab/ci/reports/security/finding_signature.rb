# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        class FindingSignature
          include VulnerabilityFindingFingerprintHelpers

          attr_accessor :algorithm_type, :signature_value

          def initialize(params = {})
            @algorithm_type = params.dig(:algorithm_type)
            @signature_value = params.dig(:signature_value)
          end

          def priority
            ::Vulnerabilities::FindingFingerprint.priority(algorithm_type)
          end

          def signature_sha
            Digest::SHA1.digest(signature_value)
          end

          def fingerprint_hex
            fingerprint_sha256.unpack1("H*")
          end

          def to_hash
            {
              algorithm_type: algorithm_type,
              signature_sha: signature_sha
            }
          end

          def valid?
            ::Vulnerabilities::FindingSignature.algorithm_types.key?(algorithm_type)
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
