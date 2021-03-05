# frozen_string_literal: true

module Dora
  # DevOps Research and Assessment (DORA) key metrics. Deployment Frequency,
  # Lead Time for Changes, Change Failure Rate and Time to Restore Service
  # are tracked as daily summary.
  # Reference: https://cloud.google.com/blog/products/devops-sre/using-the-four-keys-to-measure-your-devops-performance
  class DailyMetrics < ApplicationRecord
    belongs_to :environment

    self.table_name = 'dora_daily_metrics'

    scope :in_range_of, -> (environments, before, after) do
      where(environment: environments)
        .where('date >= ?', after)
        .where('date <= ?', before)
    end

    class << self
      def refresh!(environment, date)
        raise ArgumentError unless environment.is_a?(::Environment) && date.is_a?(Date)

        deployment_frequency = deployment_frequency(environment, date)
        lead_time_for_changes = lead_time_for_changes(environment, date)

        # This query is concurrent safe upsert with the unique index.
        connection.execute(<<~SQL)
          INSERT INTO #{table_name} (
            environment_id,
            date,
            deployment_frequency,
            lead_time_for_changes_in_seconds
          )
          VALUES (
            #{environment.id},
            #{ActiveRecord::Base.connection.quote(date.to_s)},
            (#{deployment_frequency}),
            (#{lead_time_for_changes})
          )
          ON CONFLICT (environment_id, date)
          DO UPDATE SET
            deployment_frequency = (#{deployment_frequency}),
            lead_time_for_changes_in_seconds = (#{lead_time_for_changes})
        SQL
      end

      def aggregate_deployment_frequency_all
        select('SUM(deployment_frequency) AS data').first.data
      end

      def aggregate_deployment_frequency_monthly
        select("DATE_TRUNC('month', date)::date AS month, SUM(deployment_frequency) AS data")
          .group("DATE_TRUNC('month', date)")
          .order('month ASC')
          .map { |row| { row.month.to_s => row.data } }
      end

      def aggregate_deployment_frequency_daily
        select("date, SUM(deployment_frequency) AS data")
          .group('date')
          .order('date ASC')
          .map { |row| { row.date.to_s => row.data } }
      end

      def aggregate_lead_time_for_changes_all
        select('(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY lead_time_for_changes)) AS data').first.data
      end

      def aggregate_lead_time_for_changes_monthly
        select("DATE_TRUNC('month', date)::date AS month, (PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY lead_time_for_changes)) AS data")
          .group("DATE_TRUNC('month', date)")
          .order('month ASC')
          .map { |row| { row.month.to_s => row.data } }
      end

      def aggregate_lead_time_for_changes_daily
        select("date, (PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY lead_time_for_changes)) AS data")
          .group('date')
          .order('date ASC')
          .map { |row| { row.date.to_s => row.data } }
      end

      private

      # Compose a query to calculate "Deployment Frequency" of the date
      def deployment_frequency(environment, date)
        deployments = Deployment.arel_table

        deployments
          .project(deployments[:id].count)
          .where(eligible_deployments(environment, date))
          .to_sql
      end

      # Compose a query to calculate "Lead Time for Changes" of the date
      def lead_time_for_changes(environment, date)
        deployments = Deployment.arel_table
        deployment_merge_requests = DeploymentMergeRequest.arel_table
        merge_request_metrics = MergeRequest::Metrics.arel_table

        deployments
          .project(
            Arel.sql(
              'PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY EXTRACT(EPOCH FROM (deployments.finished_at - merge_request_metrics.merged_at)))'
            )
          )
          .join(deployment_merge_requests).on(
            deployment_merge_requests[:deployment_id].eq(deployments[:id])
          )
          .join(merge_request_metrics).on(
            merge_request_metrics[:merge_request_id].eq(deployment_merge_requests[:merge_request_id])
          )
          .where(eligible_deployments(environment, date))
          .to_sql
      end

      def eligible_deployments(environment, date)
        deployments = Deployment.arel_table

        [deployments[:environment_id].eq(environment.id),
         deployments[:finished_at].gteq(date.beginning_of_day),
         deployments[:finished_at].lteq(date.end_of_day),
         deployments[:status].eq(Deployment.statuses[:success])].reduce(&:and)
      end
    end
  end
end
