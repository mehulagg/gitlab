# frozen_string_literal: true

module Analytics
  module Deployments
    module Frequency
      # This class is to aggregate deployments data at project-level or group-level
      # for calculating the frequency.
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

          frequencies = deployments_grouped.map do |grouped_start_date, grouped_deploys|
            {
              value: grouped_deploys.count,
              from: grouped_start_date,
              to: deployments_grouped_end_date(grouped_start_date)
            }
          end

          success(frequencies: frequencies)
        end

        private

        def validate
          unless start_date
            return error(_("Parameter `from` must be specified"), :bad_request)
          end

          if start_date > end_date
            return error(_("Parameter `to` is before the `from` date"), :bad_request)
          end

          if days_between > QUARTER_DAYS
            return error(_("Date range is greater than %{quarter_days} days") % { quarter_days: QUARTER_DAYS },
                         :bad_request)
          end

          unless VALID_INTERVALS.include?(interval)
            return error(_("Parameter `interval` must be one of (\"%{valid_intervals}\")") % { valid_intervals: VALID_INTERVALS.join('", "') }, :bad_request)
          end

          unless can?(current_user, :read_dora4_analytics, container)
            error(_("You do not have permission to access deployment frequencies"), :forbidden)
          end
        end

        def interval
          params[:interval] || INTERVAL_ALL
        end

        def start_date
          params[:from]
        end

        def end_date
          strong_memoize(:end_date) do
            params[:to] || DateTime.current
          end
        end

        def days_between
          (end_date - start_date).to_i
        end

        def deployments_grouped
          case interval
          when INTERVAL_ALL
            { start_date => deployments }
          when INTERVAL_MONTHLY
            deployments.group_by { |d| d.finished_at.beginning_of_month }
          when INTERVAL_DAILY
            deployments.group_by { |d| d.finished_at.to_date }
          end
        end

        def deployments_grouped_end_date(deployments_grouped_start_date)
          case interval
          when INTERVAL_ALL
            end_date
          when INTERVAL_MONTHLY
            deployments_grouped_start_date + 1.month
          when INTERVAL_DAILY
            deployments_grouped_start_date + 1.day
          end
        end

        def container_params
          if container.is_a?(Project)
            { project: container }
          elsif container.is_a?(Group)
            { group: container }
          else
            {}
          end
        end

        def deployments
          ::DeploymentsFinder.new(
            **container_params,
            environment: params[:environment],
            status: :success,
            finished_before: end_date,
            finished_after: start_date,
            order_by: :finished_at,
            sort: :asc
          ).execute
        end
      end
    end
  end
end
