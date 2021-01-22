# frozen_string_literal: true

module Analytics
  module Deployments
    module Frequency
      # This class is to aggregate deployments data for project or group
      # to calculate the frequency.
      class AggregateService < BaseContainerService
        include Gitlab::Utils::StrongMemoize

        QUARTER_DAYS = 3.months / 1.day
        INTERVAL_ALL = 'all'.freeze
        INTERVAL_MONTHLY = 'monthly'.freeze
        INTERVAL_DAILY = 'daily'.freeze
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
            Analytics::Deployments::Frequency.new(
              container: contianer,
              value: grouped_deploys.count,
              from: grouped_start_date,
              to: deployments_grouped_end_date(grouped_start_date)
            )
          end

          success(frequencies: frequencies)
        end

        private

        def validate
          if start_date > end_date
            return error("Parameter `to` is before the `from` date", :bad_request)
          end

          if days_between > QUARTER_DAYS
            return error("Date range is greater than #{QUARTER_DAYS} days", :bad_request)
          end

          unless for_group?
            return error("Group level aggregation is not supported yet", :not_implemented)
          end

          unless can?(current_user, :read_project_activity_analytics, container)
            return error("Date range is greater than #{QUARTER_DAYS} days", :unauthorized)
          end
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
  
        def interval
          self.interval || INTERVAL_ALL
        end
  
        def for_project?
          container&.is_a?(Project)
        end
  
        def for_group?
          container&.is_a?(Group)
        end
  
        def deployments
          ::DeploymentsFinder.new(
            project: container,
            environment: params[:environment],
            status: :success,
            finished_before: end_date,
            finished_after: start_date,
            order_by: :finished_at,
            sort: :acs,
            preload: false
          ).execute
        end
      end
    end
  end
end
