# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProjectsHelper do
  let_it_be_with_refind(:project) { create(:project) }

  before do
    helper.instance_variable_set(:@project, project)
  end

  describe 'default_clone_protocol' do
    context 'when gitlab.config.kerberos is enabled and user is logged in' do
      it 'returns krb5 as default protocol' do
        allow(Gitlab.config.kerberos).to receive(:enabled).and_return(true)
        allow(helper).to receive(:current_user).and_return(double)

        expect(helper.send(:default_clone_protocol)).to eq('krb5')
      end
    end
  end

  describe '#can_import_members?' do
    let(:owner) { project.owner }

    before do
      allow(helper).to receive(:current_user) { owner }
    end

    it 'returns false if membership is locked' do
      allow(helper).to receive(:membership_locked?) { true }
      expect(helper.can_import_members?).to eq false
    end

    it 'returns true if membership is not locked' do
      allow(helper).to receive(:membership_locked?) { false }
      expect(helper.can_import_members?).to eq true
    end
  end

  describe '#show_compliance_framework_badge?' do
    it 'returns false if compliance framework setting is not present' do
      expect(helper.show_compliance_framework_badge?(project)).to be_falsey
    end

    it 'returns true if compliance framework setting is present' do
      project = build_stubbed(:project, :with_compliance_framework)

      expect(helper.show_compliance_framework_badge?(project)).to be_truthy
    end
  end

  describe '#membership_locked?' do
    let(:project) { build_stubbed(:project, group: group) }
    let(:group) { nil }

    context 'when project has no group' do
      let(:project) { Project.new }

      it 'is false' do
        expect(helper).not_to be_membership_locked
      end
    end

    context 'with group_membership_lock enabled' do
      let(:group) { build_stubbed(:group, membership_lock: true) }

      it 'is true' do
        expect(helper).to be_membership_locked
      end
    end

    context 'with global LDAP membership lock enabled' do
      before do
        stub_application_setting(lock_memberships_to_ldap: true)
      end

      context 'and group membership_lock disabled' do
        let(:group) { build_stubbed(:group, membership_lock: false) }

        it 'is true' do
          expect(helper).to be_membership_locked
        end
      end
    end
  end

  describe '#group_project_templates_count' do
    let_it_be(:user) { create(:user) }
    let_it_be(:parent_group) { create(:group, name: 'parent-group') }
    let_it_be(:template_group) { create(:group, parent: parent_group, name: 'template-group') }
    let_it_be(:template_project) { create(:project, group: template_group, name: 'template-project') }

    before_all do
      parent_group.update!(custom_project_templates_group_id: template_group.id)
      parent_group.add_owner(user)
    end

    before do
      allow(helper).to receive(:current_user).and_return(user)
    end

    specify do
      expect(helper.group_project_templates_count(parent_group.id)).to eq 1
    end

    context 'when template project is pending deletion' do
      before do
        template_project.update!(marked_for_deletion_at: Date.current)
      end

      specify do
        expect(helper.group_project_templates_count(parent_group.id)).to eq 0
      end
    end
  end

  describe '#project_security_dashboard_config' do
    let_it_be(:user) { create(:user) }
    let_it_be(:group) { create(:group) }
    let_it_be(:project) { create(:project, :repository, group: group) }

    subject { helper.project_security_dashboard_config(project) }

    before do
      group.add_owner(user)
      allow(helper).to receive(:current_user).and_return(user)
    end

    context 'project without vulnerabilities' do
      let(:expected_value) do
        {
          has_vulnerabilities: 'false',
          empty_state_svg_path: start_with('/assets/illustrations/security-dashboard_empty'),
          security_dashboard_help_path: '/help/user/application_security/security_dashboard/index',
          project_full_path: project.full_path,
          no_vulnerabilities_svg_path: start_with('/assets/illustrations/issues-')
        }
      end

      it { is_expected.to match(expected_value) }
    end

    context 'project with vulnerabilities' do
      let(:base_values) do
        {
          has_vulnerabilities: 'true',
          project: { id: project.id, name: project.name },
          project_full_path: project.full_path,
          vulnerabilities_export_endpoint: "/api/v4/security/projects/#{project.id}/vulnerability_exports",
          no_vulnerabilities_svg_path: start_with('/assets/illustrations/issues-'),
          empty_state_svg_path: start_with('/assets/illustrations/security-dashboard-empty-state'),
          dashboard_documentation: '/help/user/application_security/security_dashboard/index',
          security_dashboard_help_path: '/help/user/application_security/security_dashboard/index',
          not_enabled_scanners_help_path: help_page_path('user/application_security/index', anchor: 'quick-start'),
          no_pipeline_run_scanners_help_path: "/#{project.full_path}/-/pipelines/new",
          auto_fix_documentation: help_page_path('user/application_security/index', anchor: 'auto-fix-merge-requests'),
          auto_fix_mrs_path: end_with('/merge_requests?label_name=GitLab-auto-fix')
        }
      end

      before do
        create(:vulnerability, project: project)
      end

      context 'without pipeline' do
        before do
          allow(project).to receive(:latest_pipeline_with_security_reports).and_return(nil)
        end

        it { is_expected.to match(base_values) }
      end

      context 'with pipeline' do
        let(:pipeline_created_at) { '1881-05-19T00:00:00Z' }
        let(:pipeline) { build_stubbed(:ci_pipeline, project: project, created_at: pipeline_created_at) }
        let(:pipeline_values) do
          {
            pipeline: {
              id: pipeline.id,
              path: "/#{project.full_path}/-/pipelines/#{pipeline.id}",
              created_at: pipeline_created_at,
              security_builds: {
                failed: {
                  count: 0,
                  path: "/#{project.full_path}/-/pipelines/#{pipeline.id}/failures"
                }
              }
            }
          }
        end

        before do
          allow(project).to receive(:latest_pipeline_with_security_reports).and_return(pipeline)
        end

        it { is_expected.to match(base_values.merge!(pipeline_values)) }
      end
    end
  end

  describe '#sidebar_security_paths' do
    let(:expected_security_paths) do
      %w[
        projects/security/configuration#show
        projects/security/sast_configuration#show
        projects/security/api_fuzzing_configuration#show
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

    subject { helper.sidebar_security_paths }

    it { is_expected.to eq(expected_security_paths) }
  end

  describe '#sidebar_on_demand_scans_paths' do
    let(:expected_on_demand_scans_paths) do
      %w[
        projects/on_demand_scans#index
        projects/on_demand_scans#new
        projects/on_demand_scans#edit
      ]
    end

    subject { helper.sidebar_on_demand_scans_paths }

    it { is_expected.to eq(expected_on_demand_scans_paths) }
  end

  describe '#sidebar_security_configuration_paths' do
    let(:expected_security_configuration_paths) do
      %w[
        projects/security/configuration#show
        projects/security/sast_configuration#show
        projects/security/api_fuzzing_configuration#show
        projects/security/dast_profiles#show
        projects/security/dast_site_profiles#new
        projects/security/dast_site_profiles#edit
        projects/security/dast_scanner_profiles#new
        projects/security/dast_scanner_profiles#edit
      ]
    end

    subject { helper.sidebar_security_configuration_paths }

    it { is_expected.to eq(expected_security_configuration_paths) }
  end

  describe '#get_project_nav_tabs' do
    using RSpec::Parameterized::TableSyntax

    where(:ability, :nav_tabs) do
      :read_dependencies                          | [:dependencies]
      :read_feature_flag                          | [:operations]
      :read_licenses                              | [:licenses]
      :read_project_security_dashboard            | [:security, :security_configuration]
      :read_threat_monitoring                     | [:threat_monitoring]
      :read_incident_management_oncall_schedule   | [:oncall_schedule]
    end

    with_them do
      let_it_be(:user) { create(:user) }

      before do
        allow(helper).to receive(:can?) { false }
        allow(helper).to receive(:current_user).and_return(user)
      end

      subject do
        helper.send(:get_project_nav_tabs, project, user)
      end

      context 'when the feature is not available' do
        before do
          allow(helper).to receive(:can?).with(user, ability, project).and_return(false)
        end

        it 'does not include the nav tabs' do
          is_expected.not_to include(*nav_tabs)
        end
      end

      context 'when the feature is available' do
        before do
          allow(helper).to receive(:can?).with(user, ability, project).and_return(true)
        end

        it 'includes the nav tabs' do
          is_expected.to include(*nav_tabs)
        end
      end
    end
  end

  describe '#top_level_link' do
    let(:user) { build(:user) }

    subject { helper.top_level_link(project) }

    before do
      allow(helper).to receive(:can?).and_return(false)
      allow(helper).to receive(:current_user).and_return(user)
    end

    context 'when user can read project security dashboard and audit events' do
      before do
        allow(helper).to receive(:can?).with(user, :read_project_security_dashboard, project).and_return(true)
        allow(helper).to receive(:can?).with(user, :read_project_audit_events, project).and_return(true)
      end

      it { is_expected.to eq("/#{project.full_path}/-/security/dashboard") }
    end

    context 'when user can read audit events' do
      before do
        allow(helper).to receive(:can?).with(user, :read_project_security_dashboard, project).and_return(false)
        allow(helper).to receive(:can?).with(user, :read_project_audit_events, project).and_return(true)
      end

      context 'when the feature is enabled' do
        before do
          stub_licensed_features(audit_events: true)
        end

        it { is_expected.to eq("/#{project.full_path}/-/audit_events") }
      end

      context 'when the feature is disabled' do
        before do
          stub_licensed_features(audit_events: false)
        end

        it { is_expected.to eq("/#{project.full_path}/-/dependencies") }
      end
    end

    context "when user can't read both project security dashboard and audit events" do
      before do
        allow(helper).to receive(:can?).with(user, :read_project_security_dashboard, project).and_return(false)
        allow(helper).to receive(:can?).with(user, :read_project_audit_events, project).and_return(false)
      end

      it { is_expected.to eq("/#{project.full_path}/-/dependencies") }
    end
  end

  describe '#top_level_qa_selector' do
    let(:user) { build(:user) }

    subject { helper.top_level_qa_selector(project) }

    before do
      allow(helper).to receive(:can?).and_return(false)
      allow(helper).to receive(:current_user).and_return(user)
    end

    context 'when user can read project security dashboard and audit events' do
      before do
        allow(helper).to receive(:can?).with(user, :read_project_security_dashboard, project).and_return(true)
        allow(helper).to receive(:can?).with(user, :read_project_audit_events, project).and_return(true)
      end

      it { is_expected.to eq('security_dashboard_link') }
    end

    context 'when user can read audit events' do
      before do
        allow(helper).to receive(:can?).with(user, :read_project_security_dashboard, project).and_return(false)
        allow(helper).to receive(:can?).with(user, :read_project_audit_events, project).and_return(true)
      end

      context 'when the feature is enabled' do
        before do
          stub_licensed_features(audit_events: true)
        end

        it { is_expected.to eq('audit_events_settings_link') }
      end

      context 'when the feature is disabled' do
        before do
          stub_licensed_features(audit_events: false)
        end

        it { is_expected.to eq('dependency_list_link') }
      end
    end

    context "when user can't read both project security dashboard and audit events" do
      before do
        allow(helper).to receive(:can?).with(user, :read_project_security_dashboard, project).and_return(false)
        allow(helper).to receive(:can?).with(user, :read_project_audit_events, project).and_return(false)
      end

      it { is_expected.to eq('dependency_list_link') }
    end
  end

  describe '#show_discover_project_security?' do
    using RSpec::Parameterized::TableSyntax

    let_it_be(:user) { create(:user) }

    where(
      gitlab_com?: [true, false],
      user?: [true, false],
      security_dashboard_feature_available?: [true, false],
      can_admin_namespace?: [true, false]
    )

    with_them do
      it 'returns the expected value' do
        allow(::Gitlab).to receive(:com?) { gitlab_com? }
        allow(helper).to receive(:current_user) { user? ? user : nil }
        allow(project).to receive(:feature_available?) { security_dashboard_feature_available? }
        allow(helper).to receive(:can?) { can_admin_namespace? }

        expected_value = user? && gitlab_com? && !security_dashboard_feature_available? && can_admin_namespace?

        expect(helper.show_discover_project_security?(project)).to eq(expected_value)
      end
    end
  end

  describe '#remove_project_message' do
    subject { helper.remove_project_message(project) }

    before do
      allow(project).to receive(:adjourned_deletion?).and_return(enabled)
    end

    context 'when project has delayed deletion enabled' do
      let(:enabled) { true }

      specify do
        deletion_date = helper.permanent_deletion_date(Time.now.utc)

        expect(subject).to eq "Deleting a project places it into a read-only state until #{deletion_date}, at which point the project will be permanently deleted. Are you ABSOLUTELY sure?"
      end
    end

    context 'when project has delayed deletion disabled' do
      let(:enabled) { false }

      specify do
        expect(subject).to eq "You are going to delete #{project.full_name}. Deleted projects CANNOT be restored! Are you ABSOLUTELY sure?"
      end
    end
  end

  describe '#scheduled_for_deletion?' do
    context 'when project is NOT scheduled for deletion' do
      it { expect(helper.scheduled_for_deletion?(project)).to be false }
    end

    context 'when project is scheduled for deletion' do
      let_it_be(:archived_project) { create(:project, :archived, marked_for_deletion_at: 10.minutes.ago) }

      it { expect(helper.scheduled_for_deletion?(archived_project)).to be true }
    end
  end

  describe '#can_view_operations_tab?' do
    let_it_be(:user) { create(:user) }

    before do
      allow(helper).to receive(:current_user).and_return(user)
      allow(helper).to receive(:can?).and_return(false)
    end

    subject { helper.send(:can_view_operations_tab?, user, project) }

    where(:ability) do
      [
        :read_incident_management_oncall_schedule
      ]
    end

    with_them do
      it 'includes operations tab' do
        allow(helper).to receive(:can?).with(user, ability, project).and_return(true)

        is_expected.to be(true)
      end

      context 'when operations feature is disabled' do
        it 'does not include operations tab' do
          allow(helper).to receive(:can?).with(user, ability, project).and_return(true)
          project.project_feature.update_attribute(:operations_access_level, ProjectFeature::DISABLED)

          is_expected.to be(false)
        end
      end
    end
  end
end
