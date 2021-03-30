# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        class FindingTracking
          attr_accessor :algorithm_type, :tracking_value

          def initialize(params = {})
            @algorithm_type = params.dig(:algorithm_type)
            @tracking_value = params.dig(:tracking_value)
          end

          def tracking_sha
            Digest::SHA1.digest(tracking_value)
          end

          def to_h
            {
              algorithm_type: algorithm_type,
              tracking_sha: tracking_sha
            }
          end

          def valid?
            ::Vulnerabilities::FindingTracking.algorithm_types.key?(algorithm_type)
          end
        end
      end
    end
  end
end
