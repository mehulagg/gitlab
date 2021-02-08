# frozen_string_literal: true

module Projects
  module Security
    class ConfigurationPresenter < Gitlab::View::Presenter::Delegated
      include Gitlab::Utils::StrongMemoize
      include AutoDevopsHelper
      include LatestPipelineInformation

      presents :project

      SCAN_DOCS = {
        container_scanning: 'user/application_security/container_scanning/index',
        dast: 'user/application_security/dast/index',
        dast_profiles: 'user/application_security/dast/index',
        dependency_scanning: 'user/application_security/dependency_scanning/index',
        license_management: 'user/compliance/license_compliance/index',
        license_scanning: 'user/compliance/license_compliance/index',
        sast: 'user/application_security/sast/index',
        secret_detection: 'user/application_security/secret_detection/index',
        coverage_fuzzing: 'user/application_security/coverage_fuzzing/index',
        api_fuzzing: 'user/application_security/api_fuzzing/index'
      }.freeze

      def self.localized_scan_descriptions
        {
          container_scanning: _('Check your Docker images for known vulnerabilities.'),
          dast: _('Analyze a review version of your web application.'),
          dast_profiles: _('Saved scan settings and target site settings which are reusable.'),
          dependency_scanning: _('Analyze your dependencies for known vulnerabilities.'),
          license_management: _('Search your project dependencies for their licenses and apply policies.'),
          license_scanning: _('Search your project dependencies for their licenses and apply policies.'),
          sast: _('Analyze your source code for known vulnerabilities.'),
          secret_detection: _('Analyze your source code and git history for secrets.'),
          coverage_fuzzing: _('Find bugs in your code with coverage-guided fuzzing.'),
          api_fuzzing: _('Find bugs in your code with API fuzzing.')
        }.freeze
      end

      def self.localized_scan_names
        {
          container_scanning: _('Container Scanning'),
          dast: _('Dynamic Application Security Testing (DAST)'),
          dast_profiles: _('DAST Profiles'),
          dependency_scanning: _('Dependency Scanning'),
          license_management: 'License Management',
          license_scanning: _('License Compliance'),
          sast: _('Static Application Security Testing (SAST)'),
          secret_detection: _('Secret Detection'),
          coverage_fuzzing: _('Coverage Fuzzing'),
          api_fuzzing: _('API Fuzzing')
        }.freeze
      end

      def to_h
        {
          auto_devops_enabled: auto_devops_source?,
          auto_devops_help_page_path: help_page_path('topics/autodevops/index'),
          create_sast_merge_request_path: project_security_configuration_sast_path(project),
          auto_devops_path: auto_devops_settings_path(project),
          can_enable_auto_devops: can_enable_auto_devops?,
          features: features,
          help_page_path: help_page_path('user/application_security/index'),
          latest_pipeline_path: latest_pipeline_path,
          auto_fix_enabled: autofix_enabled,
          can_toggle_auto_fix_settings: auto_fix_permission,
          gitlab_ci_present: gitlab_ci_present?,
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

      def gitlab_ci_present?
        latest_pipeline.try(:config_path) == Gitlab::FileDetector::PATTERNS[:gitlab_ci]
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

        # TODO: remove this line with #8912
        license_compliance_substitute(scans)

        dast_profiles_insert(scans)
      end

      def latest_pipeline_path
        return help_page_path('ci/pipelines') unless latest_default_branch_pipeline

        project_pipeline_path(self, latest_default_branch_pipeline)
      end

      # In this method we define if License Compliance feature is configured
      # by looking into `license_scanning` and `license_management` reports
      # in 13.0 support for `license_management` report type is scheduled to be dropped.
      # With this change we won't need this method anymore.
      def license_compliance_substitute(scans)
        license_management = scans.find { |scan_type| scan_type[:name] == localized_scan_names[:license_management] }
        license_compliance_config = license_management.fetch(:configured, false)

        scans.delete(license_management)

        if license_compliance_config
          scans.map do |scan_type|
            scan_type[:configured] = true if scan_type[:name] == _('License Compliance')
            scan_type[:status] = s_('SecurityConfiguration|Enabled') if scan_type[:name] == _('License Compliance')
          end
        end

        scans
      end

      # DAST On-demand scans is a static (non job) entry.  Add it manually following DAST
      def dast_profiles_insert(scans)
        index = scans.index { |scan| scan[:name] == localized_scan_names[:dast] }

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
          description: self.class.localized_scan_descriptions[type],
          link: help_page_path(SCAN_DOCS[type]),
          configuration_path: configuration_path(type),
          name: localized_scan_names[type]
        }
      end

      def scan_types
        ::Security::SecurityJobsFinder.allowed_job_types + ::Security::LicenseComplianceJobsFinder.allowed_job_types
      end

      def localized_scan_names
        @localized_scan_names ||= self.class.localized_scan_names
      end

      def project_settings
        project.security_setting
      end

      def configuration_path(type)
        {
          sast: project_security_configuration_sast_path(project),
          dast_profiles: project_security_configuration_dast_profiles_path(project),
          api_fuzzing: ::Feature.enabled?(:api_fuzzing_configuration_ui, project, default_enabled: :yaml) ? project_security_configuration_api_fuzzing_path(project) : nil
        }[type]
      end
    end
  end
end
