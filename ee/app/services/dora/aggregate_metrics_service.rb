# frozen_string_literal: true

module Dora
  class AggregateMetricsService < ::BaseContainerService
    INTERVAL_ALL = 'all'
    INTERVAL_MONTHLY = 'monthly'
    INTERVAL_DAILY = 'daily'

    MAX_RANGE = 1.year / 1.day
    DEFAULT_AFTER = 1.year.ago.to_date
    DEFAULT_BEFORE = Time.current.to_date
    DEFAULT_ENVIRONMENT_TIER = 'production'
    DEFAULT_INTERVAL = INTERVAL_DAILY

    VALID_INTERVALS = [
      INTERVAL_ALL,
      INTERVAL_MONTHLY,
      INTERVAL_DAILY
    ].freeze

    def execute
      if error = validate
        return error
      end

      case params[:metric]
      when 'deployment_frequency'
        success(data: aggregate_deployment_frequency)
      when 'lead_time_for_changes'
        success(data: aggregate_lead_time_for_changes)
      else
        error('Unknown metric', :bad_request)
      end
    end

    private

    def validate
      unless (before - after) <= MAX_RANGE
        return error("Date range is greater than #{MAX_RANGE} days", :bad_request)
      end

      unless project? || group?
        return error('Unknown scope', :bad_request)
      end

      unless Environment.tiers[environment_tier]
        return error('Unknown environment tier', :bad_request)
      end

      unless VALID_INTERVALS.include?(interval)
        return error("The interval must be one of (#{VALID_INTERVALS.join('", "')})", :bad_request)
      end

      unless can?(current_user, :read_dora_metrics, container)
        return error('You do not have permission to access dora metrics', :forbidden)
      end
    end

    def aggregate_deployment_frequency
      case interval
      when INTERVAL_ALL
        eligible_dora_daily_metrics.aggregate_deployment_frequency_all
      when INTERVAL_MONTHLY
        eligible_dora_daily_metrics.aggregate_deployment_frequency_monthly
      when INTERVAL_DAILY
        eligible_dora_daily_metrics.aggregate_deployment_frequency_daily
      end
    end

    def aggregate_lead_time_for_changes
      case interval
      when INTERVAL_ALL
        eligible_dora_daily_metrics.aggregate_lead_time_for_changes_all
      when INTERVAL_MONTHLY
        eligible_dora_daily_metrics.aggregate_lead_time_for_changes_monthly
      when INTERVAL_DAILY
        eligible_dora_daily_metrics.aggregate_lead_time_for_changes_daily
      end
    end

    def eligible_dora_daily_metrics
      ::Dora::DailyMetrics.in_range_of(environments, before, after)
    end

    def environments
      Environment.for_project(target_projects).for_tier(environment_tier)
    end

    def target_projects
      if project?
        [container]
      elsif group?
        container.all_projects
      else
        []
      end
    end

    def project?
      container.is_a?(Project)
    end

    def group?
      container.is_a?(Group)
    end

    def after
      params[:after] || DEFAULT_AFTER
    end

    def before
      params[:before] || DEFAULT_BEFORE
    end

    def environment_tier
      params[:environment_tier] || DEFAULT_ENVIRONMENT_TIER
    end

    def interval
      params[:interval] || DEFAULT_INTERVAL
    end
  end
end
