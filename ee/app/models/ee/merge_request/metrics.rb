# frozen_string_literal: true

module EE
  module MergeRequest
    module Metrics
      extend ActiveSupport::Concern

      class_methods do
        def review_time_field
          @review_time_field ||= Arel.sql("LEAST(merge_request_metrics.first_comment_at, merge_request_metrics.first_approved_at, merge_request_metrics.first_reassigned_at)")
        end
      end

      def review_time
        return unless review_start_at

        review_end_at - review_start_at
      end

      def review_start_at
        [first_comment_at, first_approved_at, first_reassigned_at].compact.min
      end

      def review_end_at
        merged_at || Time.current
      end
    end
  end
end
