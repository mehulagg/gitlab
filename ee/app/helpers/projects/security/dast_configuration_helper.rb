# frozen_string_literal: true

module Projects::Security::DastConfigurationHelper
  def dast_configuration_data(project)
    {
      security_configuration_path: project_security_configuration_path(project),
      full_path: project.full_path,
      gitlab_ci_yaml_edit_path: Rails.application.routes.url_helpers.project_ci_pipeline_editor_path(project)
    }
  end
end
