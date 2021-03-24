# frozen_string_literal: true

module Gitlab
  module Usage
    module Metrics
      module Instrumentations
        class UuidMetric < BaseMetric
          def value
            alt_usage_data { Gitlab::CurrentSettings.uuid }
          end
        end
      end
    end
  end
end
