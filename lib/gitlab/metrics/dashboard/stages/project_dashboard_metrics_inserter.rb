# frozen_string_literal: true

module Gitlab
  module Metrics
    module Dashboard
      module Stages
        # Acts on metrics which have been ingested from
        # source-controlled dashboards
        class ProjectDashboardMetricsInserter < BaseStage
          # For each metric in the dashboard config, attempts to
          # find a corresponding database record. If found,
          # includes the record's id in the dashboard config.
          def transform!
            metrics = ::PrometheusMetricsFinder
                        .new(common: false, project: project, group: :project_dashboard)
                        .execute

            for_metrics do |metric|
              metric_record = metrics.find { |m| m.identifier == metric[:id] }
              metric[:metric_id] = metric_record.id if metric_record
            end
          end
        end
      end
    end
  end
end
