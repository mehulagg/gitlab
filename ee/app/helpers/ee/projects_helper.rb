# frozen_string_literal: true

module EE
  module ProjectsHelper
    extend ::Gitlab::Utils::Override

    override :sidebar_settings_paths
    def sidebar_settings_paths
      super + %w[
        operations#show
      ]
    end

    override :sidebar_repository_paths
    def sidebar_repository_paths
      super + %w(path_locks)
    end

    override :sidebar_operations_paths
    def sidebar_operations_paths
      super + %w[
        oncall_schedules
      ]
    end

    override :get_project_nav_tabs
    def get_project_nav_tabs(project, current_user)
      nav_tabs = super

      nav_tabs += get_project_security_nav_tabs(project, current_user)

      if can?(current_user, :read_code_review_analytics, project)
        nav_tabs << :code_review
      end

      if can?(current_user, :read_project_merge_request_analytics, project)
        nav_tabs << :merge_request_analytics
      end

      if project.feature_available?(:issues_analytics) && can?(current_user, :read_project, project)
        nav_tabs << :issues_analytics
      end

      if project.insights_available?
        nav_tabs << :project_insights
      end

      if can?(current_user, :read_requirement, project)
        nav_tabs << :requirements
      end

      if can?(current_user, :read_incident_management_oncall_schedule, project)
        nav_tabs << :oncall_schedule
      end

      nav_tabs
    end

    override :project_permissions_settings
    def project_permissions_settings(project)
      super.merge(
        requirementsAccessLevel: project.requirements_access_level
      )
    end

    override :project_permissions_panel_data
    def project_permissions_panel_data(project)
      super.merge(
        requirementsAvailable: project.feature_available?(:requirements)
      )
    end

    override :default_url_to_repo
    def default_url_to_repo(project = @project)
      case default_clone_protocol
      when 'krb5'
        project.kerberos_url_to_repo
      else
        super
      end
    end

    override :extra_default_clone_protocol
    def extra_default_clone_protocol
      if alternative_kerberos_url? && current_user
        "krb5"
      else
        super
      end
    end

    override :remove_project_message
    def remove_project_message(project)
      return super unless project.adjourned_deletion?

      date = permanent_deletion_date(Time.now.utc)
      _("Deleting a project places it into a read-only state until %{date}, at which point the project will be permanently deleted. Are you ABSOLUTELY sure?") %
        { date: date }
    end

    def approvals_app_data(project = @project)
      { data: { 'project_id': project.id,
      'can_edit': can_modify_approvers.to_s,
      'project_path': expose_path(api_v4_projects_path(id: project.id)),
      'settings_path': expose_path(api_v4_projects_approval_settings_path(id: project.id)),
      'rules_path': expose_path(api_v4_projects_approval_settings_rules_path(id: project.id)),
      'allow_multi_rule': project.multiple_approval_rules_available?.to_s,
      'eligible_approvers_docs_path': help_page_path('user/project/merge_requests/merge_request_approvals', anchor: 'eligible-approvers'),
      'security_approvals_help_page_path': help_page_path('user/application_security/index.md', anchor: 'security-approvals-in-merge-requests'),
      'security_configuration_path': project_security_configuration_path(project),
      'vulnerability_check_help_page_path': help_page_path('user/application_security/index', anchor: 'enabling-security-approvals-within-a-project'),
      'license_check_help_page_path': help_page_path('user/application_security/index', anchor: 'enabling-license-approvals-within-a-project') } }
    end

    def can_modify_approvers(project = @project)
      can?(current_user, :modify_approvers_rules, project)
    end

    def permanent_delete_message(project)
      message = _('This action will %{strongOpen}permanently delete%{strongClose} %{codeOpen}%{project}%{codeClose} %{strongOpen}immediately%{strongClose}, including its repositories and all content: issues, merge requests, etc.')
      html_escape(message) % remove_message_data(project)
    end

    def marked_for_removal_message(project)
      date = permanent_deletion_date(Time.now.utc)
      message = _('This action will %{strongOpen}permanently delete%{strongClose} %{codeOpen}%{project}%{codeClose} %{strongOpen}on %{date}%{strongClose}, including its repositories and all content: issues, merge requests, etc.')
      html_escape(message) % remove_message_data(project).merge(date: date)
    end

    def permanent_deletion_date(date)
      (date + ::Gitlab::CurrentSettings.deletion_adjourned_period.days).strftime('%F')
    end

    # Given the current GitLab configuration, check whether the GitLab URL for Kerberos is going to be different than the HTTP URL
    def alternative_kerberos_url?
      ::Gitlab.config.alternative_gitlab_kerberos_url?
    end

    def can_change_push_rule?(push_rule, rule, context)
      return true if push_rule.global?

      can?(current_user, :"change_#{rule}", context)
    end

    def ci_cd_projects_available?
      ::License.feature_available?(:ci_cd_projects) && import_sources_enabled?
    end

    def merge_pipelines_available?
      return false unless @project.builds_enabled?

      @project.feature_available?(:merge_pipelines)
    end

    def merge_trains_available?
      return false unless @project.builds_enabled?

      @project.feature_available?(:merge_trains)
    end

    def sidebar_security_paths
      %w[
        projects/security/configuration#show
        projects/security/sast_configuration#show
        projects/security/vulnerabilities#show
        projects/security/vulnerability_report#index
        projects/security/dashboard#index
        projects/on_demand_scans#index
        projects/on_demand_scans#new
        projects/on_demand_scans#edit
        projects/security/dast_profiles#show
        projects/security/dast_site_profiles#new
        projects/security/dast_site_profiles#edit
        projects/security/dast_scanner_profiles#new
        projects/security/dast_scanner_profiles#edit
        projects/dependencies#index
        projects/licenses#index
        projects/threat_monitoring#show
        projects/threat_monitoring#new
        projects/threat_monitoring#edit
        projects/audit_events#index
      ]
    end

    def sidebar_external_tracker_paths
      %w[
        projects/integrations/jira/issues#index
      ]
    end

    def sidebar_on_demand_scans_paths
      %w[
        projects/on_demand_scans#index
        projects/on_demand_scans#new
        projects/on_demand_scans#edit
      ]
    end

    def sidebar_security_configuration_paths
      %w[
        projects/security/configuration#show
        projects/security/sast_configuration#show
        projects/security/dast_profiles#show
        projects/security/dast_site_profiles#new
        projects/security/dast_site_profiles#edit
        projects/security/dast_scanner_profiles#new
        projects/security/dast_scanner_profiles#edit
      ]
    end

    def size_limit_message(project)
      show_lfs = project.lfs_enabled? ? 'including files in LFS' : ''

      "The total size of this project's repository #{show_lfs} will be limited to this size. 0 for unlimited. Leave empty to inherit the group/global value."
    end

    override :membership_locked?
    def membership_locked?
      group = @project.group

      return false unless group

      group.membership_lock? || ::Gitlab::CurrentSettings.lock_memberships_to_ldap?
    end

    def group_project_templates_count(group_id)
      allowed_subgroups = current_user.available_subgroups_with_custom_project_templates(group_id)

      ::Project.in_namespace(allowed_subgroups).not_aimed_for_deletion.count
    end

    def project_security_dashboard_config(project)
      if project.vulnerabilities.none?
        {
          has_vulnerabilities: 'false',
          empty_state_svg_path: image_path('illustrations/security-dashboard_empty.svg'),
          security_dashboard_help_path: help_page_path('user/application_security/security_dashboard/index'),
          no_vulnerabilities_svg_path: image_path('illustrations/issues.svg'),
          project_full_path: project.full_path
        }.merge!(security_dashboard_pipeline_data(project))
      else
        {
          has_vulnerabilities: 'true',
          project: { id: project.id, name: project.name },
          project_full_path: project.full_path,
          vulnerabilities_export_endpoint: api_v4_security_projects_vulnerability_exports_path(id: project.id),
          empty_state_svg_path: image_path('illustrations/security-dashboard-empty-state.svg'),
          no_vulnerabilities_svg_path: image_path('illustrations/issues.svg'),
          dashboard_documentation: help_page_path('user/application_security/security_dashboard/index'),
          not_enabled_scanners_help_path: help_page_path('user/application_security/index', anchor: 'quick-start'),
          no_pipeline_run_scanners_help_path: new_project_pipeline_path(project),
          security_dashboard_help_path: help_page_path('user/application_security/security_dashboard/index'),
          auto_fix_documentation: help_page_path('user/application_security/index', anchor: 'auto-fix-merge-requests'),
          auto_fix_mrs_path: project_merge_requests_path(@project, label_name: 'GitLab-auto-fix')
        }.merge!(security_dashboard_pipeline_data(project))
      end
    end

    def can_create_feedback?(project, feedback_type)
      feedback = Vulnerabilities::Feedback.new(project: project, feedback_type: feedback_type)
      can?(current_user, :create_vulnerability_feedback, feedback)
    end

    def create_vulnerability_feedback_issue_path(project)
      if can_create_feedback?(project, :issue)
        project_vulnerability_feedback_index_path(project)
      end
    end

    def create_vulnerability_feedback_merge_request_path(project)
      if can_create_feedback?(project, :merge_request)
        project_vulnerability_feedback_index_path(project)
      end
    end

    def create_vulnerability_feedback_dismissal_path(project)
      if can_create_feedback?(project, :dismissal)
        project_vulnerability_feedback_index_path(project)
      end
    end

    def any_project_nav_tab?(tabs)
      tabs.any? { |tab| project_nav_tab?(tab) }
    end

    def top_level_link(project)
      return project_security_dashboard_index_path(project) if project_nav_tab?(:security)
      return project_audit_events_path(project) if project_nav_tab?(:audit_events)

      project_dependencies_path(project)
    end

    def top_level_qa_selector(project)
      return 'security_dashboard_link' if project_nav_tab?(:security)
      return 'audit_events_settings_link' if project_nav_tab?(:audit_events)

      'dependency_list_link'
    end

    def show_discover_project_security?(project)
      !!current_user &&
        ::Gitlab.com? &&
        !project.feature_available?(:security_dashboard) &&
        can?(current_user, :admin_namespace, project.root_ancestor)
    end

    override :can_import_members?
    def can_import_members?
      super && !membership_locked?
    end

    def show_compliance_framework_badge?(project)
      project&.compliance_framework_setting&.compliance_management_framework.present?
    end

    def scheduled_for_deletion?(project)
      project.marked_for_deletion_at.present?
    end

    private

    def get_project_security_nav_tabs(project, current_user)
      nav_tabs = []

      if can?(current_user, :read_project_security_dashboard, project)
        nav_tabs << :security
        nav_tabs << :security_configuration
      end

      if can?(current_user, :read_on_demand_scans, @project)
        nav_tabs << :on_demand_scans
      end

      if can?(current_user, :read_dependencies, project)
        nav_tabs << :dependencies
      end

      if can?(current_user, :read_licenses, project)
        nav_tabs << :licenses
      end

      if can?(current_user, :read_threat_monitoring, project)
        nav_tabs << :threat_monitoring
      end

      if show_audit_events?(project)
        nav_tabs << :audit_events
      end

      nav_tabs
    end

    def show_audit_events?(project)
      can?(current_user, :read_project_audit_events, project) &&
        (project.feature_available?(:audit_events) || show_promotions?(current_user))
    end

    def remove_message_data(project)
      {
        project: project.path,
        strongOpen: '<strong>'.html_safe,
        strongClose: '</strong>'.html_safe,
        codeOpen: '<code>'.html_safe,
        codeClose: '</code>'.html_safe
      }
    end

    def security_dashboard_pipeline_data(project)
      pipeline = project.latest_pipeline_with_security_reports
      return {} unless pipeline

      {
        pipeline: {
          id: pipeline.id,
          path: pipeline_path(pipeline),
          created_at: pipeline.created_at.to_s(:iso8601),
          security_builds: {
            failed: {
              count: pipeline.latest_failed_security_builds.count,
              path: failures_project_pipeline_path(pipeline.project, pipeline)
            }
          }
        }
      }
    end

    override :view_operations_tab_ability
    def view_operations_tab_ability
      super + [
        :read_incident_management_oncall_schedule
      ]
    end
  end
end
