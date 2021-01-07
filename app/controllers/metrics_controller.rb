# frozen_string_literal: true

class MetricsController < ActionController::Base
  include RequiresWhitelistedMonitoringClient

  protect_from_forgery with: :exception, prepend: true

  def index
    response = if Gitlab::Metrics.prometheus_metrics_enabled?
                 metrics_service.metrics_text
               else
                 help_page = help_page_url('administration/monitoring/prometheus/gitlab_metrics',
                                           anchor: 'gitlab-prometheus-metrics'
                                          )
                 "# Metrics are disabled, see: #{help_page}\n"
               end

    render plain: response, content_type: 'text/plain; version=0.0.4'
  end

  def vm
    # perform a major mark-and-sweep before collecting stats
    GC.start

    render json: Gitlab::Metrics::System.summary
  end

  private

  def metrics_service
    @metrics_service ||= MetricsService.new
  end
end
