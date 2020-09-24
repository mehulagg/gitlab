# frozen_string_literal: true

module Analytics
  class RefreshApprovalsData
    include MergeRequestMetricsRefresh

    # Override `MergeRequestMetricsRefresh#initialize` to accept single MR only
    def initialize(merge_request)
      super
    end

    private

    def metric_already_present?(metrics)
      metrics.first_approved_at
    end

    def update_metric!(metrics)
      metrics.update!(
        first_approved_at: MergeRequestMetricsCalculator.new(metrics.merge_request).first_approved_at
      )
    end
  end
end
