# frozen_string_literal: true

module Gitlab
  module Usage
    module Metrics
      module Instrumentations
        class LicenseMD5Metric < GenericMetric
          def value
            ::License.current.md5
          end
        end
      end
    end
  end
end
