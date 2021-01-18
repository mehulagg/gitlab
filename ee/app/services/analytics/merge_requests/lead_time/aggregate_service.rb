# frozen_string_literal: true

module Analytics
  module MergeRequests
    module LeadTime
      # This class is to aggregate merge requests data at project-level or group-level
      # for calculating the lead time.
      class AggregateService < BaseContainerService
        include Gitlab::Utils::StrongMemoize

        QUARTER_DAYS = 3.months / 1.day
        INTERVAL_ALL = 'all'
        INTERVAL_MONTHLY = 'monthly'
        INTERVAL_DAILY = 'daily'
        VALID_INTERVALS = [
          INTERVAL_ALL,
          INTERVAL_MONTHLY,
          INTERVAL_DAILY
        ].freeze

        def execute
          if error = validate
            return error
          end

          success(lead_times: lead_times)
        end

        private

        def validate
          unless start_date
            return error(_('Parameter `from` must be specified'), :bad_request)
          end

          if start_date > end_date
            return error(_('Parameter `to` is before the `from` date'), :bad_request)
          end

          if days_between > QUARTER_DAYS
            return error(_('Date range is greater than %{quarter_days} days') % { quarter_days: QUARTER_DAYS },
                         :bad_request)
          end

          unless container.is_a?(Project)
            return error(_('Only project level aggregation is supported'))
          end

          unless VALID_INTERVALS.include?(interval)
            return error(_("Parameter `interval` must be one of (\"%{valid_intervals}\")") % { valid_intervals: VALID_INTERVALS.join('", "') }, :bad_request)
          end

          unless can?(current_user, :read_dora4_analytics, container)
            return error(_('You do not have permission to access lead times'), :forbidden)
          end

          nil
        end

        def interval
          params[:interval] || INTERVAL_ALL
        end

        def start_date
          params[:from]
        end

        def end_date
          params[:to] || DateTime.current
        end

        def days_between
          (end_date - start_date).to_i
        end

        def lead_times
          strong_memoize(:lead_times) do
            merge_requests_grouped.map do |grouped_start_date, grouping|
              {
                value: average_lead_time(grouping),
                from: grouped_start_date,
                to: merge_requests_grouped_end_date(grouped_start_date)
              }
            end
          end
        end

        def merge_requests_grouped
          strong_memoize(:merge_requests_grouped) do
            case interval
            when INTERVAL_ALL
              { start_date => merge_requests }
            when INTERVAL_MONTHLY
              merge_requests.group_by { |d| d.merged_at.beginning_of_month }
            when INTERVAL_DAILY
              merge_requests.group_by { |d| d.merged_at.to_date }
            end
          end
        end

        def average_lead_time(grouping)
          size = grouping.count
          return 0 if size == 0

          total = grouping.inject(0) do |sum, mr|
            sum + (mr.merged_at - mr.merge_request.created_at).to_i / 1.minute
          end

          total / size
        end

        def merge_requests_grouped_end_date(merge_requests_grouped_start_date)
          case interval
          when INTERVAL_ALL
            end_date
          when INTERVAL_MONTHLY
            merge_requests_grouped_start_date + 1.month
          when INTERVAL_DAILY
            merge_requests_grouped_start_date + 1.day
          end
        end

        def merge_requests
          strong_memoize(:merge_requests) do
            # rubocop: disable CodeReuse/ActiveRecord
            ::MergeRequest::Metrics.by_target_project(container)
                                   .merged_after(start_date)
                                   .merged_before(end_date)
                                   .order('merged_at')
            # rubocop: enable CodeReuse/ActiveRecord
          end
        end
      end
    end
  end
end
