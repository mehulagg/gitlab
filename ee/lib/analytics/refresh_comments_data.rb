# frozen_string_literal: true

module Analytics
  class RefreshCommentsData
    include MergeRequestMetricsRefresh

    class << self
      def for_note(note)
        merge_requests = note.merge_requests&.including_metrics

        new(*merge_requests) unless merge_requests.nil?
      end
    end

    private

    def metric_already_present?(metrics)
      metrics.first_comment_at
    end

    def update_metric!(metrics)
      metrics.update!(
        first_comment_at: MergeRequestMetricsCalculator.new(metrics.merge_request).first_comment_at
      )
    end
  end
end
