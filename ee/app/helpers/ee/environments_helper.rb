# frozen_string_literal: true

module EE
  module EnvironmentsHelper
    extend ::Gitlab::Utils::Override

    override :environments_list_data
    def environments_list_data
      ee_environments_list_data = {
        "user_callouts_path" => user_callouts_path,
        "lock_promotion_svg_path" => image_path('illustrations/lock_promotion.svg'),
        "help_canary_deployments_path" => help_page_path('user/project/canary_deployments')
      }

      super.merge(ee_environments_list_data)
    end

    override :environments_folder_list_view_data
    def environments_folder_list_view_data
      ee_environments_folder_list_view_data = {
        "user_callouts_path" => user_callouts_path,
        "lock_promotion_svg_path" => image_path('illustrations/lock_promotion.svg'),
        "help_canary_deployments_path" => help_page_path('user/project/canary_deployments')
      }

      super.merge(ee_environments_folder_list_view_data)
    end

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
