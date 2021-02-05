# frozen_string_literal: true

module EE
  module EnvironmentsHelper
    extend ::Gitlab::Utils::Override

    override :project_metrics_data
    def project_metrics_data(project)
      ee_metrics_data = {}
      ee_metrics_data['logs_path'] = project_logs_path(project) if can?(current_user, :read_pod_logs, project)

      super.merge(ee_metrics_data)
    end

    override :project_and_environment_metrics_data
    def project_and_environment_metrics_data(project, environment)
      ee_metrics_data = {}

      # overwrites project_metrics_data logs_path if environment is available
      ee_metrics_data['logs_path'] = project_logs_path(project, environment_name: environment.name) if can?(current_user, :read_pod_logs, project)

      super.merge(ee_metrics_data)
    end
  end
end
