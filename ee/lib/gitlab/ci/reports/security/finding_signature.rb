# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        class FindingSignature
          attr_accessor :algorithm_type, :signature_value

          def initialize(params = {})
            @algorithm_type = params.dig(:algorithm_type)
            @signature_value = params.dig(:signature_value)
          end

          def signature_sha
            Digest::SHA1.digest(signature_value)
          end

          def to_h
            {
              algorithm_type: algorithm_type,
              signature_sha: signature_sha
            }
          end

          def valid?
            ::Vulnerabilities::FindingSignature.algorithm_types.key?(algorithm_type)
          end
        end
      end
    end
  end
end
