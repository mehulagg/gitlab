# frozen_string_literal: true

module EE
  module MergeRequestMetricsService
    extend ::Gitlab::Utils::Override

    delegate :merge_request, to: :@merge_request_metrics

    override :merge
    def merge(event)
      data = {
        merged_by_id: event.author_id,
        merged_at: event.created_at
      }.merge(metrics_calculator.productivity_data, metrics_calculator.line_counts_data)

      update!(data)
    end

    private

    def metrics_calculator
      @metrics_calculator ||= ::Analytics::MergeRequestMetricsCalculator.new(merge_request)
    end
  end
end
