# frozen_string_literal: true

module Projects::OnDemandScansHelper
  def on_demand_scans_data(project)
    {
      'help-page-path' => help_page_path('user/application_security/dast/index', anchor: 'on-demand-scans'),
      'empty-state-svg-path' => image_path('illustrations/empty-state/ondemand-scan-empty.svg'),
      'default-branch' => project.default_branch,
      'project-path' => project.path_with_namespace,
      'profiles-library-path' => project_profiles_path(project),
      'new-site-profile-path' => new_project_dast_site_profile_path(project)
    }
  end
end
