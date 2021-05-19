# frozen_string_literal: true

module Projects::Security::DastConfigurationHelper
  def dast_configuration_data(project)
    {
      security_configuration_path: project_security_configuration_path(project),
      full_path: project.full_path,
      dast_documentation_path: help_page_path('user/application_security/dast/index')
    }
  end
end
