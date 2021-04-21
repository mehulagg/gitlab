# frozen_string_literal: true

module Gitlab
  module Usage
    module Metrics
      module Instrumentations
        class UuidMetric < BaseMetric
          value do
            Gitlab::CurrentSettings.uuid
          end
        end
      end
    end
  end
end
