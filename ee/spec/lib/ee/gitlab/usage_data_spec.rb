# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::UsageData do
  include UsageDataHelpers

  before do
    stub_usage_data_connections
  end

  describe '.data' do
    # using Array.new to create a different creator User for each of the projects
    let_it_be(:projects) { Array.new(3) { create(:project, :repository, creator: create(:user, group_view: :security_dashboard)) } }
    let(:count_data) { subject[:counts] }

    let_it_be(:board) { create(:board, project: projects[0]) }

    before_all do
      projects.last.creator.block # to get at least one non-active User

      pipeline = create(:ci_pipeline, project: projects[0])
      create(:ci_build, name: 'container_scanning', pipeline: pipeline)
      create(:ci_build, name: 'dast', pipeline: pipeline)
      create(:ci_build, name: 'dependency_scanning', pipeline: pipeline)
      create(:ci_build, name: 'license_management', pipeline: pipeline)
      create(:ee_ci_build, name: 'license_scanning', pipeline: pipeline)
      create(:ci_build, name: 'sast', pipeline: pipeline)
      create(:ci_build, name: 'secret_detection', pipeline: pipeline)

      create(:prometheus_alert, project: projects[0])
      create(:prometheus_alert, project: projects[0])
      create(:prometheus_alert, project: projects[1])

      create(:service, project: projects[1], type: 'JenkinsService', active: true)

      create(:package, project: projects[0])
      create(:package, project: projects[0])
      create(:package, project: projects[1])

      create(:project_tracing_setting, project: projects[0])
      create(:operations_feature_flag, project: projects[0])

      create(:issue, project: projects[1])
      create(:issue, health_status: :on_track, project: projects[1])
      create(:issue, health_status: :at_risk, project: projects[1])

      # for group_view testing
      create(:user) # user with group_view = NULL (should be counted as having default value 'details')
      create(:user, group_view: :details)

      # Status Page
      create(:status_page_setting, project: projects[0], enabled: true)
      create(:status_page_setting, project: projects[1], enabled: false)
      # 1 published issue on 1 projects with status page enabled
      create(:issue, project: projects[0])
      create(:issue, :published, project: projects[0])
      create(:issue, :published, project: projects[1])
    end

    subject { described_class.data }

    it 'gathers usage data' do
      expect(subject.keys).to include(*%i(
        historical_max_users
        license_add_ons
        license_plan
        license_expires_at
        license_starts_at
        license_user_count
        license_trial
        licensee
        license_md5
        license_id
        elasticsearch_enabled
        geo_enabled
        license_trial_ends_on
      ))
    end

    it 'gathers usage counts', :aggregate_failures do
      expect(count_data[:boards]).to eq(1)
      expect(count_data[:projects]).to eq(3)

      expect(count_data.keys).to include(*%i(
        confidential_epics
        container_scanning_jobs
        dast_jobs
        dependency_list_usages_total
        dependency_scanning_jobs
        epics
        epics_deepest_relationship_level
        feature_flags
        geo_nodes
        geo_event_log_max_id
        issues_with_health_status
        ldap_group_links
        ldap_keys
        ldap_users
        license_management_jobs
        licenses_list_views
        operations_dashboard_default_dashboard
        operations_dashboard_users_with_projects_added
        pod_logs_usages_total
        projects_jenkins_active
        projects_jira_dvcs_cloud_active
        projects_jira_dvcs_server_active
        projects_mirrored_with_pipelines_enabled
        projects_reporting_ci_cd_back_to_github
        projects_with_packages
        projects_with_prometheus_alerts
        projects_with_tracing_enabled
        sast_jobs
        secret_detection_jobs
        status_page_incident_publishes
        status_page_incident_unpublishes
        status_page_issues
        status_page_projects
        user_preferences_group_overview_details
        user_preferences_group_overview_security_dashboard
        template_repositories
      ))

      expect(count_data[:projects_jenkins_active]).to eq(1)
      expect(count_data[:projects_with_prometheus_alerts]).to eq(2)
      expect(count_data[:projects_with_packages]).to eq(2)
      expect(count_data[:feature_flags]).to eq(1)
      expect(count_data[:status_page_projects]).to eq(1)
      expect(count_data[:status_page_issues]).to eq(1)
      expect(count_data[:issues_with_health_status]).to eq(2)
    end

    it 'has integer value for epic relationship level' do
      expect(count_data[:epics_deepest_relationship_level]).to be_a_kind_of(Integer)
    end

    it 'has integer values for all counts' do
      expect(count_data.values).to all(be_a_kind_of(Integer))
    end

    it 'gathers security products usage data' do
      expect(count_data[:container_scanning_jobs]).to eq(1)
      expect(count_data[:dast_jobs]).to eq(1)
      expect(count_data[:dependency_scanning_jobs]).to eq(1)
      expect(count_data[:license_management_jobs]).to eq(2)
      expect(count_data[:sast_jobs]).to eq(1)
      expect(count_data[:secret_detection_jobs]).to eq(1)
    end

    it 'correctly shows failure for combined license management' do
      allow(Gitlab::Database::BatchCount).to receive(:batch_count).and_raise(ActiveRecord::StatementInvalid)

      expect(count_data[:license_management_jobs]).to eq(-1)
    end

    it 'gathers group overview preferences usage data', :aggregate_failures do
      expect(subject[:counts][:user_preferences_group_overview_details]).to eq(User.active.count - 2) # we have exactly 2 active users with security dashboard set
      expect(subject[:counts][:user_preferences_group_overview_security_dashboard]).to eq 2
    end

    it 'includes a recording_ee_finished_at timestamp' do
      expect(subject[:recording_ee_finished_at]).to be_a(Time)
    end
  end

  describe '.features_usage_data_ee' do
    subject { described_class.features_usage_data_ee }

    it 'gathers feature usage data of EE' do
      expect(subject[:elasticsearch_enabled]).to eq(Gitlab::CurrentSettings.elasticsearch_search?)
      expect(subject[:geo_enabled]).to eq(Gitlab::Geo.enabled?)
      expect(subject[:license_trial_ends_on]).to eq(License.trial_ends_on)
    end
  end

  describe '.license_usage_data' do
    subject { described_class.license_usage_data }

    it 'gathers license data' do
      license = ::License.current

      expect(subject[:license_md5]).to eq(Digest::MD5.hexdigest(license.data))
      expect(subject[:license_id]).to eq(license.license_id)
      expect(subject[:historical_max_users]).to eq(::HistoricalData.max_historical_user_count)
      expect(subject[:licensee]).to eq(license.licensee)
      expect(subject[:license_user_count]).to eq(license.restricted_user_count)
      expect(subject[:license_starts_at]).to eq(license.starts_at)
      expect(subject[:license_expires_at]).to eq(license.expires_at)
      expect(subject[:license_add_ons]).to eq(license.add_ons)
      expect(subject[:license_trial]).to eq(license.trial?)
    end
  end

  describe '.requirements_counts' do
    subject { described_class.requirements_counts }

    context 'when requirements are disabled' do
      it 'returns empty hash' do
        stub_licensed_features(requirements: false)

        expect(subject).to eq({})
      end
    end

    context 'when requirements are enabled' do
      it 'returns created requirements count' do
        stub_licensed_features(requirements: true)

        create_list(:requirement, 2)

        expect(subject).to eq({ requirements_created: 2 })
      end
    end
  end

  describe '.service_desk_counts' do
    subject { described_class.service_desk_counts }

    let(:project) { create(:project, :service_desk_enabled) }

    it 'gathers Service Desk data' do
      create_list(:issue, 2, confidential: true, author: User.support_bot, project: project)

      allow(::EE::Gitlab::ServiceDesk).to receive(:enabled?).with(anything).and_return(true)

      expect(subject).to eq(service_desk_enabled_projects: 1,
                            service_desk_issues: 2)
    end
  end

  describe 'code owner approval required' do
    before do
      create(:protected_branch, code_owner_approval_required: true)

      create(:protected_branch,
        code_owner_approval_required: true,
        project: create(:project, :archived))

      create(:protected_branch,
        code_owner_approval_required: true,
        project: create(:project, pending_delete: true))
    end

    it 'counts the projects actively requiring code owner approval' do
      expect(described_class.system_usage_data[:counts][:projects_enforcing_code_owner_approval]).to eq(1)
    end
  end

  describe '.operations_dashboard_usage' do
    subject { described_class.operations_dashboard_usage }

    before_all do
      blocked_user = create(:user, :blocked, dashboard: 'operations')
      user_with_ops_dashboard = create(:user, dashboard: 'operations')

      create(:users_ops_dashboard_project, user: blocked_user)
      create(:users_ops_dashboard_project, user: user_with_ops_dashboard)
      create(:users_ops_dashboard_project, user: user_with_ops_dashboard)
      create(:users_ops_dashboard_project)
    end

    it 'gathers data on operations dashboard' do
      expect(subject.keys).to include(*%i(
        operations_dashboard_default_dashboard
        operations_dashboard_users_with_projects_added
      ))
    end

    it 'bases counts on active users', :aggregate_failures do
      expect(subject[:operations_dashboard_default_dashboard]).to eq(1)
      expect(subject[:operations_dashboard_users_with_projects_added]).to eq(2)
    end
  end

  describe '.uncached_data' do
    describe '.usage_activity_by_stage' do
      it 'includes usage_activity_by_stage data' do
        expect(described_class.uncached_data).to include(:usage_activity_by_stage)
        expect(described_class.uncached_data).to include(:usage_activity_by_stage_monthly)
      end

      context 'for configure' do
        it 'includes accurate usage_activity_by_stage data' do
          for_defined_days_back do
            user = create(:user)
            project = create(:project, creator: user)
            create(:slack_service, project: project)
            create(:slack_slash_commands_service, project: project)
            create(:prometheus_service, project: project)
          end

          expect(described_class.uncached_data[:usage_activity_by_stage][:configure]).to include(
            projects_slack_notifications_active: 2,
            projects_slack_slash_active: 2,
            projects_with_prometheus_alerts: 2
          )
          expect(described_class.uncached_data[:usage_activity_by_stage_monthly][:configure]).to include(
            projects_slack_notifications_active: 1,
            projects_slack_slash_active: 1,
            projects_with_prometheus_alerts: 1
          )
        end
      end

      context 'for create' do
        it 'includes accurate usage_activity_by_stage data' do
          for_defined_days_back do
            user = create(:user)
            project = create(:project, :repository_private, :github_imported,
                              :test_repo, :remote_mirror, creator: user)
            merge_request = create(:merge_request, source_project: project)
            create(:deploy_key, user: user)
            create(:key, user: user)
            create(:project, creator: user)
            create(:project, creator: user, disable_overriding_approvers_per_merge_request: true)
            create(:project, creator: user, disable_overriding_approvers_per_merge_request: false)
            create(:protected_branch, project: project)
            create(:remote_mirror, project: project)
            create(:snippet, author: user)
            create(:suggestion, note: create(:note, project: project))
            create(:code_owner_rule, merge_request: merge_request, approvals_required: 3)
            create(:code_owner_rule, merge_request: merge_request, approvals_required: 7)
            create_list(:code_owner_rule, 3, approvals_required: 2)
            create_list(:code_owner_rule, 2)
          end

          expect(described_class.uncached_data[:usage_activity_by_stage][:create]).to eq(
            deploy_keys: 2,
            keys: 2,
            merge_requests: 12,
            projects_enforcing_code_owner_approval: 0,
            merge_requests_with_optional_codeowners: 4,
            merge_requests_with_required_codeowners: 8,
            projects_with_disable_overriding_approvers_per_merge_request: 2,
            projects_without_disable_overriding_approvers_per_merge_request: 16,
            projects_imported_from_github: 2,
            projects_with_repositories_enabled: 12,
            protected_branches: 2,
            remote_mirrors: 2,
            snippets: 2,
            suggestions: 2
          )
          expect(described_class.uncached_data[:usage_activity_by_stage_monthly][:create]).to eq(
            deploy_keys: 1,
            keys: 1,
            merge_requests: 6,
            projects_enforcing_code_owner_approval: 0,
            merge_requests_users: 0,
            merge_requests_with_optional_codeowners: 2,
            merge_requests_with_required_codeowners: 4,
            projects_with_disable_overriding_approvers_per_merge_request: 1,
            projects_without_disable_overriding_approvers_per_merge_request: 8,
            projects_imported_from_github: 1,
            projects_with_repositories_enabled: 6,
            protected_branches: 1,
            remote_mirrors: 1,
            snippets: 1,
            suggestions: 1
          )
        end
      end

      context 'for manage' do
        it 'includes accurate usage_activity_by_stage data' do
          stub_config(
            ldap:
              { enabled: true, servers: ldap_server_config }
          )

          for_defined_days_back do
            user = create(:user)
            create(:key, type: 'LDAPKey', user: user)
            create(:group_member, ldap: true, user: user)
            create(:cycle_analytics_group_stage)
            create(:compliance_framework_project_setting)
          end

          expect(described_class.uncached_data[:usage_activity_by_stage][:manage]).to include(
            ldap_keys: 2,
            ldap_users: 2,
            value_stream_management_customized_group_stages: 2,
            projects_with_compliance_framework: 2,
            ldap_servers: 2,
            ldap_group_sync_enabled: true,
            ldap_admin_sync_enabled: true,
            group_saml_enabled: true
          )
          expect(described_class.uncached_data[:usage_activity_by_stage_monthly][:manage]).to include(
            ldap_keys: 1,
            ldap_users: 1,
            value_stream_management_customized_group_stages: 2,
            projects_with_compliance_framework: 2,
            ldap_servers: 2,
            ldap_group_sync_enabled: true,
            ldap_admin_sync_enabled: true,
            group_saml_enabled: true
          )
        end

        def ldap_server_config
          {
            'main' =>
            {
              'provider_name' => 'ldapmain',
              'group_base'    => 'ou=groups',
              'admin_group'   => 'my_group'
            },
            'secondary' =>
            {
              'provider_name' => 'ldapsecondary',
              'group_base'    => nil,
              'admin_group'   => nil
            }
          }
        end
      end

      context 'for monitor' do
        it 'includes accurate usage_activity_by_stage data' do
          for_defined_days_back do
            user    = create(:user, dashboard: 'operations')
            project = create(:project, creator: user)
            create(:users_ops_dashboard_project, user: user)
            create(:prometheus_service, project: project)
            create(:project_error_tracking_setting, project: project)
            create(:project_tracing_setting, project: project)
          end

          expect(described_class.uncached_data[:usage_activity_by_stage][:monitor]).to include(
            operations_dashboard_users_with_projects_added: 2,
            projects_prometheus_active: 2,
            projects_with_error_tracking_enabled: 2,
            projects_with_tracing_enabled: 2
          )
          expect(described_class.uncached_data[:usage_activity_by_stage_monthly][:monitor]).to include(
            operations_dashboard_users_with_projects_added: 1,
            projects_prometheus_active: 1,
            projects_with_error_tracking_enabled: 1,
            projects_with_tracing_enabled: 1
          )
        end
      end

      context 'for package' do
        it 'includes accurate usage_activity_by_stage data' do
          for_defined_days_back do
            create(:project, packages: [create(:package)] )
          end

          expect(described_class.uncached_data[:usage_activity_by_stage][:package]).to eq(
            projects_with_packages: 2
          )
          expect(described_class.uncached_data[:usage_activity_by_stage_monthly][:package]).to eq(
            projects_with_packages: 1
          )
        end
      end

      context 'for plan' do
        it 'includes accurate usage_activity_by_stage data' do
          stub_licensed_features(board_assignee_lists: true, board_milestone_lists: true)

          for_defined_days_back do
            user = create(:user)
            project = create(:project, creator: user)
            issue = create(:issue, project: project, author: User.support_bot)
            create(:issue, project: project, author: user)
            board = create(:board, project: project)
            create(:user_list, board: board, user: user)
            create(:milestone_list, board: board, milestone: create(:milestone, project: project), user: user)
            create(:list, board: board, label: create(:label, project: project), user: user)
            create(:note, project: project, noteable: issue, author: user)
            create(:epic, author: user)
            create(:todo, project: project, target: issue, author: user)
            create(:jira_service, :jira_cloud_service, active: true, project: create(:project, :jira_dvcs_cloud, creator: user))
            create(:jira_service, active: true, project: create(:project, :jira_dvcs_server, creator: user))
          end

          expect(described_class.uncached_data[:usage_activity_by_stage][:plan]).to eq(
            assignee_lists: 2,
            epics: 2,
            issues: 3,
            label_lists: 2,
            milestone_lists: 2,
            notes: 2,
            projects: 2,
            projects_jira_active: 2,
            projects_jira_dvcs_cloud_active: 2,
            projects_jira_dvcs_server_active: 2,
            service_desk_enabled_projects: 2,
            service_desk_issues: 2,
            todos: 2
          )
          expect(described_class.uncached_data[:usage_activity_by_stage_monthly][:plan]).to eq(
            assignee_lists: 1,
            epics: 1,
            issues: 2,
            label_lists: 1,
            milestone_lists: 1,
            notes: 1,
            projects: 1,
            projects_jira_active: 1,
            projects_jira_dvcs_cloud_active: 1,
            projects_jira_dvcs_server_active: 1,
            service_desk_enabled_projects: 1,
            service_desk_issues: 1,
            todos: 1
          )
        end
      end

      context 'for release' do
        it 'includes accurate usage_activity_by_stage data' do
          for_defined_days_back do
            create(:project, :mirror, mirror_trigger_builds: true)
          end

          expect(described_class.uncached_data[:usage_activity_by_stage][:release]).to include(
            projects_mirrored_with_pipelines_enabled: 2
          )
          expect(described_class.uncached_data[:usage_activity_by_stage_monthly][:release]).to include(
            projects_mirrored_with_pipelines_enabled: 1
          )
        end
      end

      context 'for secure' do
        let_it_be(:user) { create(:user, group_view: :security_dashboard) }

        before do
          for_defined_days_back do
            create(:ci_build, name: 'container_scanning', user: user)
            create(:ci_build, name: 'dast', user: user)
            create(:ci_build, name: 'dependency_scanning', user: user)
            create(:ci_build, name: 'license_management', user: user)
            create(:ci_build, name: 'sast', user: user)
            create(:ci_build, name: 'secret_detection', user: user)
          end
        end

        it 'includes accurate usage_activity_by_stage data' do
          expect(described_class.uncached_data[:usage_activity_by_stage_monthly][:secure]).to eq(
            user_preferences_group_overview_security_dashboard: 1,
            user_container_scanning_jobs: 1,
            user_dast_jobs: 1,
            user_dependency_scanning_jobs: 1,
            user_license_management_jobs: 1,
            user_sast_jobs: 1,
            user_secret_detection_jobs: 1
          )
        end

        it 'combines license_scanning into license_management' do
          for_defined_days_back do
            create(:ci_build, name: 'license_scanning', user: user)
          end

          expect(described_class.uncached_data[:usage_activity_by_stage_monthly][:secure]).to eq(
            user_preferences_group_overview_security_dashboard: 1,
            user_container_scanning_jobs: 1,
            user_dast_jobs: 1,
            user_dependency_scanning_jobs: 1,
            user_license_management_jobs: 2,
            user_sast_jobs: 1,
            user_secret_detection_jobs: 1
          )
        end

        it 'has to resort to 0 for counting license scan' do
          allow(Gitlab::Database::BatchCount).to receive(:batch_distinct_count).and_raise(ActiveRecord::StatementInvalid)
          allow(::Ci::Build).to receive(:distinct_count_by).and_raise(ActiveRecord::StatementInvalid)

          expect(described_class.uncached_data[:usage_activity_by_stage_monthly][:secure]).to eq(
            user_preferences_group_overview_security_dashboard: 1,
            user_container_scanning_jobs: -1,
            user_dast_jobs: -1,
            user_dependency_scanning_jobs: -1,
            user_license_management_jobs: -1,
            user_sast_jobs: -1,
            user_secret_detection_jobs: -1
          )
        end
      end

      context 'for verify' do
        it 'includes accurate usage_activity_by_stage data' do
          for_defined_days_back do
            user = create(:user)
            create(:ci_build, user: user)
            create(:ci_empty_pipeline, source: :external, user: user)
            create(:ci_empty_pipeline, user: user)
            create(:ci_pipeline, :auto_devops_source, user: user)
            create(:ci_pipeline, :repository_source, user: user)
            create(:ci_pipeline_schedule, owner: user)
            create(:ci_trigger, owner: user)
            create(:clusters_applications_runner, :installed)
            create(:github_service)
          end

          expect(described_class.uncached_data[:usage_activity_by_stage][:verify]).to eq(
            ci_builds: 2,
            ci_external_pipelines: 2,
            ci_internal_pipelines: 2,
            ci_pipeline_config_auto_devops: 2,
            ci_pipeline_config_repository: 2,
            ci_pipeline_schedules: 2,
            ci_pipelines: 2,
            ci_triggers: 2,
            clusters_applications_runner: 2,
            projects_reporting_ci_cd_back_to_github: 2
          )
          expect(described_class.uncached_data[:usage_activity_by_stage_monthly][:verify]).to eq(
            ci_builds: 1,
            ci_external_pipelines: 1,
            ci_internal_pipelines: 1,
            ci_pipeline_config_auto_devops: 1,
            ci_pipeline_config_repository: 1,
            ci_pipeline_schedules: 1,
            ci_pipelines: 1,
            ci_triggers: 1,
            clusters_applications_runner: 1,
            projects_reporting_ci_cd_back_to_github: 1
          )
        end
      end
    end
  end
end
