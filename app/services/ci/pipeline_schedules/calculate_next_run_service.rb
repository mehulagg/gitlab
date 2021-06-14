# frozen_string_literal: true

module Ci
  module PipelineSchedules
    class CalculateNextRunService < BaseService
      include Gitlab::Utils::StrongMemoize

      def execute(schedule, fallback_method:)
        @schedule = schedule

        return fallback_method.call unless ::Feature.enabled?(:ci_daily_limit_for_pipeline_schedules, project, default_enabled: :yaml)
        return fallback_method.call unless plan_cron&.cron_valid?

        now = Time.zone.now

        schedule_next_run = schedule_cron.next_time_from(now)
        return schedule_next_run if worker_cron.match?(schedule_next_run) && plan_cron.match?(schedule_next_run)

        plan_next_run = plan_cron.next_time_from(now)
        return plan_next_run if worker_cron.match?(plan_next_run)

        worker_next_run = worker_cron.next_time_from(now)
        return worker_next_run if plan_cron.match?(worker_next_run)

        worker_cron.next_time_from(plan_next_run)
      end

      private

      def schedule_cron
        strong_memoize(:schedule_cron) do
          Gitlab::Ci::CronParser.new(@schedule.cron, @schedule.cron_timezone)
        end
      end

      def worker_cron
        strong_memoize(:worker_cron) do
          Gitlab::Ci::CronParser.new(worker_cron_expression, Time.zone.name)
        end
      end

      def plan_cron
        strong_memoize(:plan_cron) do
          daily_scheduled_pipeline_limit = project.actual_limits.limit_for(:ci_daily_pipeline_schedule_triggers)

          next unless daily_scheduled_pipeline_limit

          every_x_minutes = (1.day.in_minutes / daily_scheduled_pipeline_limit).to_i

          Gitlab::Ci::CronParser.parse_natural("every #{every_x_minutes} minutes", Time.zone.name)
        end
      end

      def worker_cron_expression
        Settings.cron_jobs['pipeline_schedule_worker']['cron']
      end
    end
  end
end
