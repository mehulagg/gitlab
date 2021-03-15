# frozen_string_literal: true

module Dora
  class AggregateMetricsService < ::BaseContainerService
    MAX_RANGE = 3.months / 1.day
    DEFAULT_ENVIRONMENT_TIER = 'production'
    DEFAULT_INTERVAL = Dora::DailyMetrics::INTERVAL_DAILY

    def execute
      if error = validate
        return error
      end

      data = ::Dora::DailyMetrics
        .for_environments(environments)
        .in_range_of(start_date, end_date)
        .aggregate_for!(metric, interval)

      success(data: data)
    end

    private

    def validate
      unless (end_date - start_date) <= MAX_RANGE
        return error(_("Date range must be shorter than %{max_range} days.") % { max_range: MAX_RANGE },
                     :bad_request)
      end

      unless start_date < end_date
        return error(_('The start date must be ealier than the end date.'), :bad_request)
      end

      unless project?
        return error(_('Container must be a project.'), :bad_request)
      end

      unless ::Dora::DailyMetrics::AVAILABLE_INTERVALS.include?(interval)
        return error(_("The interval must be one of %{intervals}.") % { intervals: ::Dora::DailyMetrics::AVAILABLE_INTERVALS.join(',') },
                     :bad_request)
      end

      unless ::Dora::DailyMetrics::AVAILABLE_METRICS.include?(metric)
        return error(_("The metric must be one of %{metrics}.") % { metrics: ::Dora::DailyMetrics::AVAILABLE_METRICS.join(',') },
                     :bad_request)
      end

      unless Environment.tiers[environment_tier]
        return error(_("The environment tier must be one of %{environment_tiers}.") % { environment_tiers: Environment.tiers.keys.join(',') },
                     :bad_request)
      end

      unless can?(current_user, :read_dora4_analytics, container)
        return error(_('You do not have permission to access dora metrics.'), :unauthorized)
      end

      nil
    end

    def environments
      Environment.for_project(container).for_tier(environment_tier)
    end

    def project?
      container.is_a?(Project)
    end

    def start_date
      params[:start_date] || 3.months.ago.to_date
    end

    def end_date
      params[:end_date] || Time.current.to_date
    end

    def environment_tier
      params[:environment_tier] || DEFAULT_ENVIRONMENT_TIER
    end

    def interval
      params[:interval] || DEFAULT_INTERVAL
    end

    def metric
      params[:metric]
    end
  end
end
