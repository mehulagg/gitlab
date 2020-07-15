# frozen_string_literal: true

# Fetches the system metrics dashboard and formats the output.
# Use Gitlab::Metrics::Dashboard::Finder to retrieve dashboards.
module Metrics
  module Dashboard
    class SystemDashboardService < ::Metrics::Dashboard::PredefinedDashboardService
      DASHBOARD_PATH = 'config/prometheus/common_metrics.yml'
      DASHBOARD_NAME = N_('Default dashboard')

      BUILD_DASHBORD_SEQUENCE = [
        STAGES::CommonMetricsInserter,
        STAGES::CustomMetricsInserter
      ].freeze

      FRONTEND_HELPERS_SEQUENCE = [
        STAGES::CustomMetricsDetailsInserter,
        STAGES::MetricEndpointInserter,
        STAGES::VariableEndpointInserter,
        STAGES::PanelIdsInserter,
        STAGES::Sorter,
        STAGES::AlertsInserter
      ].freeze

      SEQUENCE = BUILD_DASHBORD_SEQUENCE + FRONTEND_HELPERS_SEQUENCE

      class << self
        def all_dashboard_paths(_project)
          [{
            path: DASHBOARD_PATH,
            display_name: _(DASHBOARD_NAME),
            default: true,
            system_dashboard: true,
            out_of_the_box_dashboard: out_of_the_box_dashboard?
          }]
        end
      end
    end
  end
end
