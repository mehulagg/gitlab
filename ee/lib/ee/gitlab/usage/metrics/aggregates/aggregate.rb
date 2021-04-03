# frozen_string_literal: true

module EE
  module Gitlab
    module Usage
      module Metrics
        module Aggregates
          module Aggregate
            extend ActiveSupport::Concern
            extend ::Gitlab::Utils::Override

            EE_AGGREGATED_METRICS_PATH = Rails.root.join('ee/config/metrics/aggregates/*.yml')

            override :initialize
            def initialize(recorded_at)
              super
              @aggregated_metrics += load_metrics(EE_AGGREGATED_METRICS_PATH)
            end
          end
        end
      end
    end
  end
end
