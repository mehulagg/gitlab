# frozen_string_literal: true

module Gitlab
  module Metrics
    module Dashboard
      module Importers
        class PrometheusMetrics
          ALLOWED_ATTRIBUTES = %i(title query y_label unit legend group dashboard_path).freeze

          # Takes a JSON schema validated dashboard hash and
          # imports metrics to database
          def initialize(dashboard_hash, project:, dashboard_path:)
            @dashboard_hash = dashboard_hash
            @project = project
            @dashboard_path = dashboard_path
            @affected_environment_ids = []
          end

          def execute
            import
          rescue ActiveRecord::RecordInvalid, Dashboard::Transformers::Errors::BaseError
            false
          end

          def execute!
            import
          end

          private

          attr_reader :dashboard_hash, :project, :dashboard_path

          def import
            delete_stale_metrics
            create_or_update_metrics
            update_prometheus_environments
          end

          # rubocop: disable CodeReuse/ActiveRecord
          def create_or_update_metrics
            # TODO: use upsert and worker for callbacks?

            affected_metric_ids = []
            prometheus_metrics_attributes.each do |attributes|
              prometheus_metric = PrometheusMetric.find_or_initialize_by(attributes.slice(:dashboard_path, :identifier, :project))
              prometheus_metric.update!(attributes.slice(*ALLOWED_ATTRIBUTES))

              affected_metric_ids << prometheus_metric.id
            end

            @affected_environment_ids += find_alerts(affected_metric_ids).pluck(:environment_id)
          end
          # rubocop: enable CodeReuse/ActiveRecord

          def delete_stale_metrics
            identifiers_from_yml = prometheus_metrics_attributes.map { |metric_attributes| metric_attributes[:identifier] }

            stale_metrics = PrometheusMetric.for_project(project)
              .for_dashboard_path(dashboard_path)
              .for_group(Enums::PrometheusMetric.groups[:custom])
              .not_identifier(identifiers_from_yml)

            return unless stale_metrics.present?

            delete_stale_alerts(stale_metrics)
            stale_metrics.each_batch { |batch| batch.delete_all }
          end

          # rubocop: disable CodeReuse/ActiveRecord
          def delete_stale_alerts(stale_metrics)
            stale_alerts = Projects::Prometheus::AlertsFinder.new(project: project, metric: stale_metrics).execute

            @affected_environment_ids += stale_alerts.pluck(:environment_id)

            stale_alerts.each_batch { |batch| batch.delete_all }
          end
          # rubocop: enable CodeReuse/ActiveRecord

          def find_alerts(metrics)
            Projects::Prometheus::AlertsFinder.new(project: project, metric: metrics).execute
          end

          def prometheus_metrics_attributes
            @prometheus_metrics_attributes ||= begin
              Dashboard::Transformers::Yml::V1::PrometheusMetrics.new(
                dashboard_hash,
                project: project,
                dashboard_path: dashboard_path
              ).execute
            end
          end

          # rubocop: disable CodeReuse/ActiveRecord
          def update_prometheus_environments
            affected_environments = ::Environment.where(id: @affected_environment_ids.flatten.uniq, project: project)

            return unless affected_environments.present?

            affected_environments.each do |affected_environment|
              ::Clusters::Applications::ScheduleUpdateService.new(
                affected_environment.cluster_prometheus_adapter,
                project
              ).execute
            end
          end
          # rubocop: enable CodeReuse/ActiveRecord
        end
      end
    end
  end
end
