# frozen_string_literal: true

module Projects
  module Security
    class ConfigurationPresenter < Gitlab::View::Presenter::Delegated
      include Gitlab::Utils::StrongMemoize
      include AutoDevopsHelper
      include LatestPipelineInformation

      presents :project

      def to_h
        {
          auto_devops_enabled: auto_devops_source?,
          auto_devops_help_page_path: help_page_path('topics/autodevops/index'),
          auto_devops_path: auto_devops_settings_path(project),
          can_enable_auto_devops: can_enable_auto_devops?,
          features: features,
          help_page_path: help_page_path('user/application_security/index'),
          latest_pipeline_path: latest_pipeline_path,
          auto_fix_enabled: autofix_enabled,
          can_toggle_auto_fix_settings: auto_fix_permission,
          gitlab_ci_present: project.uses_default_ci_config?,
          gitlab_ci_history_path: gitlab_ci_history_path,
          auto_fix_user_path: '/' # TODO: real link will be updated with https://gitlab.com/gitlab-org/gitlab/-/issues/215669
        }
      end

      def to_html_data_attribute
        data = to_h
        data[:features] = data[:features].to_json
        data[:auto_fix_enabled] = data[:auto_fix_enabled].to_json

        data
      end

      private

      def autofix_enabled
        {
          dependency_scanning: project_settings&.auto_fix_dependency_scanning,
          container_scanning: project_settings&.auto_fix_container_scanning
        }
      end

      def can_enable_auto_devops?
        feature_available?(:builds, current_user) &&
          can?(current_user, :admin_project, self) &&
          !archived?
      end

      def gitlab_ci_history_path
        return '' if project.empty_repo?

        gitlab_ci = Gitlab::FileDetector::PATTERNS[:gitlab_ci]
        Gitlab::Routing.url_helpers.project_blame_path(project, File.join(project.default_branch_or_master, gitlab_ci))
      end

      def features
        scans = scan_types.map do |scan_type|
          if scanner_enabled?(scan_type)
            scan(scan_type, configured: true, status: auto_devops_source? ? s_('SecurityConfiguration|Enabled with Auto DevOps') : s_('SecurityConfiguration|Enabled'))
          else
            scan(scan_type, configured: false, status: s_('SecurityConfiguration|Not enabled'))
          end
        end

        dast_profiles_insert(scans)
      end

      def latest_pipeline_path
        return help_page_path('ci/pipelines') unless latest_default_branch_pipeline

        project_pipeline_path(self, latest_default_branch_pipeline)
      end

      # DAST On-demand scans is a static (non job) entry.  Add it manually following DAST
      # TODO: remove as part of https://gitlab.com/gitlab-org/gitlab/-/issues/323375
      def dast_profiles_insert(scans)
        index = scans.index { |scan| scan[:type] == :dast }

        unless index.nil?
          scans.insert(index + 1, scan(:dast_profiles, configured: true, status: s_('SecurityConfiguration|Available for on-demand DAST')))
        end

        scans
      end

      def scan(type, configured: false, status:)
        {
          type: type,
          configured: configured,
          status: status,
          configuration_path: configuration_path(type)
        }
      end

      def scan_types
        ::Security::SecurityJobsFinder.allowed_job_types + ::Security::LicenseComplianceJobsFinder.allowed_job_types
      end

      def project_settings
        project.security_setting
      end

      def configuration_path(type)
        {
          sast: project_security_configuration_sast_path(project),
          dast_profiles: project_security_configuration_dast_scans_path(project),
          api_fuzzing: ::Feature.enabled?(:api_fuzzing_configuration_ui, project, default_enabled: :yaml) ? project_security_configuration_api_fuzzing_path(project) : nil
        }[type]
      end
    end
  end
end
