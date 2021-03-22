# frozen_string_literal: true

module EE
  module Gitlab
    module Usage
      module Metrics
        module Aggregates
          module Aggregate
            extend ActiveSupport::Concern
            extend ::Gitlab::Utils::Override

            EE_AGGREGATED_METRICS_PATH = Rails.root.join('ee/lib/gitlab/usage_data_counters/aggregated_metrics/*.yml')

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
